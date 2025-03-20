extends Node2D

@export var tower_scene: PackedScene = preload("res://scenes/tower.tscn")
@export var enemy_scene: PackedScene = preload("res://scenes/enemy.tscn")
@export var building_mode: bool = false
@export var player_money: int = 500
@export var player_lives: int = 10
@export var tower_cost: int = 100
@export var enemy_reward: int = 25
@export var wave_size: int = 5
@export var wave_delay: float = 1.0

var tower_preview = null

func _ready():
	$UI/HUD/BuildUI/Tower.connect("pressed", Callable(self, "_on_tower_button_pressed"))

	# Podłączenie sygnału do istniejącego przycisku w scenie
	if $UI/HUD/BuildUI.has_node("SpawnButton"):
		$UI/HUD/BuildUI/SpawnButton.connect("pressed", Callable(self, "_on_spawn_button_pressed"))

	# Muzyka w tle
	$AudioStreamPlayer.play()

	set_process_input(true)
	update_money_ui()
	update_lives_ui()

func _process(_delta):
	if building_mode and tower_preview:
		var mouse_pos = get_global_mouse_position()
		tower_preview.position = mouse_pos

func _input(event):
	if not building_mode:
		return

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var mouse_pos = get_global_mouse_position()

			if player_money >= tower_cost:
				place_tower(mouse_pos)
				player_money -= tower_cost
				update_money_ui()
			else:
				print("Not enough money to place tower")

		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			cancel_building()

func _on_tower_button_pressed():
	print("Tower button pressed")
	building_mode = true

	if tower_preview:
		tower_preview.queue_free()

	tower_preview = tower_scene.instantiate()
	tower_preview.modulate = Color(1, 1, 1, 0.5)
	add_child(tower_preview)

func place_tower(pos):
	var new_tower = tower_scene.instantiate()
	new_tower.position = pos

	add_child(new_tower)
	if has_node("TowerCreation"):
			$TowerCreation.play()
	cancel_building()

func cancel_building():
	building_mode = false
	if tower_preview:
		tower_preview.queue_free()
		tower_preview = null

func update_money_ui():
	if $UI/HUD/UserUI.has_node("MoneyLabel"):
		$UI/HUD/UserUI/MoneyLabel.text = "Money: " + str(player_money)

func update_lives_ui():
	if $UI/HUD/UserUI.has_node("LivesLabel"):
		$UI/HUD/UserUI/LivesLabel.text = "Lives: " + str(player_lives)

func spawn_enemy():
	var enemy = enemy_scene.instantiate()
	var map_node = $Map
	var path = map_node.get_enemy_path()  # Użycie poprawionej nazwy funkcji

	# Dodanie PathFollow2D do ścieżki
	var path_follow = PathFollow2D.new()
	path.add_child(path_follow)

	# Ustawienie path_follow dla wroga
	enemy.path = path
	enemy.path_follow = path_follow

	# Podłączenie sygnałów
	enemy.connect("enemy_died", Callable(self, "_on_enemy_died"))
	enemy.connect("enemy_escaped", Callable(self, "_on_enemy_escaped"))

	# Dodanie wroga do sceny
	add_child(enemy)

func spawn_wave(num_enemies = wave_size, delay = wave_delay):
	for i in range(num_enemies):
		# Użycie timera do opóźnienia spawnu
		var timer = get_tree().create_timer(i * delay)
		timer.timeout.connect(func(): spawn_enemy())

func _on_enemy_died():
	player_money += enemy_reward
	update_money_ui()

func _on_enemy_escaped():
	player_lives -= 1
	update_lives_ui()

	if player_lives <= 0:
		print("Game Over!")
		# Tu można dodać logikę końca gry

func _on_spawn_button_pressed():
	spawn_wave()  # Używa domyślnych wartości z exportowanych zmiennych
	
func pause_music():
	$AudioStreamPlayer.stream_paused = true

func resume_music():
	$AudioStreamPlayer.stream_paused = false

func stop_music():
	$AudioStreamPlayer.stop()
