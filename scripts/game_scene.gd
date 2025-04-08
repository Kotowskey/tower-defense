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
var current_tower_type = 0
var selected_tower = null
var can_upgrade = false
var upgrade_cost = 0
var current_wave = 0
var wave_in_progress = false
var enemies_spawned = 0
var enemies_to_kill = 0

func _ready():
	if $UI/HUD/BuildUI.has_node("TowerBasic"):
		$UI/HUD/BuildUI/TowerBasic.connect("pressed", Callable(self, "_on_tower_basic_pressed"))
	
	if $UI/HUD/BuildUI.has_node("TowerArea"):
		$UI/HUD/BuildUI/TowerArea.connect("pressed", Callable(self, "_on_tower_area_pressed"))
	
	if $UI/HUD/BuildUI.has_node("TowerSniper"):
		$UI/HUD/BuildUI/TowerSniper.connect("pressed", Callable(self, "_on_tower_sniper_pressed"))
	
	if $UI/HUD/BuildUI.has_node("TowerSlow"):
		$UI/HUD/BuildUI/TowerSlow.connect("pressed", Callable(self, "_on_tower_slow_pressed"))
	
	if $UI/HUD/BuildUI.has_node("Upgrade"):
		$UI/HUD/BuildUI/Upgrade.connect("pressed", Callable(self, "_on_upgrade_pressed"))
	
	if $UI/HUD/BuildUI.has_node("SpawnButton"):
		$UI/HUD/BuildUI/SpawnButton.connect("pressed", Callable(self, "_on_spawn_button_pressed"))

	$AudioStreamPlayer.play()

	set_process_input(true)
	update_money_ui()
	update_lives_ui()
	update_upgrade_ui()
	
	if $UI/HUD/BuildUI.has_node("SpawnButton") and $UI/HUD/BuildUI/SpawnButton.has_node("Image") and $UI/HUD/BuildUI/SpawnButton/Image.has_node("Label"):
		$UI/HUD/BuildUI/SpawnButton/Image/Label.text = "START\nWAVE 1"
	
	if $UI/HUD/UserUI.has_node("WaveLabel"):
		$UI/HUD/UserUI/WaveLabel.text = "Wave: 0"

func _process(_delta):
	if building_mode and tower_preview:
		var mouse_pos = get_global_mouse_position()
		tower_preview.position = mouse_pos
	
	if selected_tower:
		var tower_node = selected_tower.get_ref()
		if tower_node:
			can_upgrade = true
			upgrade_cost = tower_node.tower_cost * tower_node.tower_level
		else:
			can_upgrade = false
			selected_tower = null
	else:
		can_upgrade = false

	update_upgrade_ui()

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if building_mode:
				var mouse_pos = get_global_mouse_position()
				var selected_tower_cost = 0
				
				match current_tower_type:
					0: selected_tower_cost = 100
					1: selected_tower_cost = 200
					2: selected_tower_cost = 300
					3: selected_tower_cost = 150
				
				if player_money >= selected_tower_cost:
					place_tower(mouse_pos)
					player_money -= selected_tower_cost
					update_money_ui()
				else:
					print("Not enough money to place tower")
			else:
				var mouse_pos = get_global_mouse_position()
				select_tower_at_position(mouse_pos)
		
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			cancel_building()
			deselect_tower()

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"): 
		toggle_pause_menu()

func toggle_pause_menu():
	var pause_menu = $UI/PauseMenu
	if pause_menu.visible:
		pause_menu.hide()
		get_tree().paused = false
		resume_music()
	else:
		pause_menu.show()
		get_tree().paused = true
		pause_music()

func _on_tower_basic_pressed():
	start_tower_placement(0)

func _on_tower_area_pressed():
	start_tower_placement(1)

func _on_tower_sniper_pressed():
	start_tower_placement(2)

func _on_tower_slow_pressed():
	start_tower_placement(3)

func start_tower_placement(tower_type):
	current_tower_type = tower_type
	building_mode = true
	deselect_tower()

	if tower_preview:
		tower_preview.queue_free()

	tower_preview = tower_scene.instantiate()
	tower_preview.tower_type = tower_type
	
	add_child(tower_preview)
	
	await get_tree().process_frame
	
	tower_preview.modulate = Color(1, 1, 1, 0.5)

func place_tower(pos):
	var new_tower = tower_scene.instantiate()
	new_tower.position = pos
	new_tower.tower_type = current_tower_type
	new_tower.add_to_group("towers")

	add_child(new_tower)
	if has_node("TowerCreation"):
		$TowerCreation.play()
	cancel_building()

func cancel_building():
	building_mode = false
	if tower_preview:
		tower_preview.queue_free()
		tower_preview = null

func select_tower_at_position(pos):
	for tower in get_tree().get_nodes_in_group("towers"):
		var tower_size = 64
		var tower_rect = Rect2(tower.position - Vector2(tower_size/2.0, tower_size/2.0), 
							  Vector2(tower_size, tower_size))
		
		if tower_rect.has_point(pos):
			deselect_tower()
			selected_tower = weakref(tower)
			tower.show_range(true)
			return
	
	deselect_tower()

func deselect_tower():
	if selected_tower and selected_tower.get_ref():
		selected_tower.get_ref().show_range(false)
	selected_tower = null

func _on_upgrade_pressed():
	if selected_tower and selected_tower.get_ref():
		var tower = selected_tower.get_ref()
		var cost = tower.tower_cost * tower.tower_level
		
		if player_money >= cost:
			player_money -= cost
			var new_cost = tower.upgrade()
			upgrade_cost = new_cost
			update_money_ui()
			if has_node("UpgradeSound"):
				$UpgradeSound.play()
		else:
			print("Not enough money to upgrade tower")

func update_money_ui():
	if $UI/HUD/UserUI.has_node("MoneyLabel"):
		$UI/HUD/UserUI/MoneyLabel.text = "Money: " + str(player_money)

func update_lives_ui():
	if $UI/HUD/UserUI.has_node("LivesLabel"):
		$UI/HUD/UserUI/LivesLabel.text = "Lives: " + str(player_lives)

func update_upgrade_ui():
	if $UI/HUD/BuildUI.has_node("Upgrade"):
		var upgrade_button = $UI/HUD/BuildUI/Upgrade
		if can_upgrade and player_money >= upgrade_cost:
			upgrade_button.disabled = false
			upgrade_button.modulate = Color(1, 1, 1, 1)
		else:
			upgrade_button.disabled = true
			upgrade_button.modulate = Color(0.5, 0.5, 0.5, 1)
		
		if upgrade_button.has_node("Label"):
			if can_upgrade:
				upgrade_button.get_node("Label").text = "Upgrade\n" + str(upgrade_cost)
			else:
				upgrade_button.get_node("Label").text = "Upgrade"

func _on_spawn_button_pressed():
	if not wave_in_progress:
		current_wave += 1
		if $UI/HUD/UserUI.has_node("WaveLabel"):
			$UI/HUD/UserUI/WaveLabel.text = "Wave: " + str(current_wave)
		if $UI/HUD/BuildUI.has_node("SpawnButton") and $UI/HUD/BuildUI/SpawnButton.has_node("StartSound"):
			$UI/HUD/BuildUI/SpawnButton/StartSound.play()
		start_wave()
	else:
		print("Wave already in progress")

func start_wave():
	wave_in_progress = true
	enemies_spawned = 0
	enemies_to_kill = wave_size + (current_wave * 2)
	
	if $UI/HUD/BuildUI.has_node("SpawnButton"):
		$UI/HUD/BuildUI/SpawnButton.disabled = true
		$UI/HUD/BuildUI/SpawnButton.modulate = Color(0.5, 0.5, 0.5, 1)
		if $UI/HUD/BuildUI/SpawnButton.has_node("Image") and $UI/HUD/BuildUI/SpawnButton/Image.has_node("Label"):
			$UI/HUD/BuildUI/SpawnButton/Image/Label.text = "IN\nPROGRESS"
	
	var wave_timer = Timer.new()
	wave_timer.wait_time = 1.0
	wave_timer.autostart = true
	wave_timer.name = "WaveTimer"
	add_child(wave_timer)
	wave_timer.connect("timeout", Callable(self, "_on_wave_timer_timeout"))
	
	var enemy_health_multiplier = 1.0 + (current_wave * 0.2)
	var enemy_speed_multiplier = 1.0 + (current_wave * 0.05)
	var spawn_delay = wave_delay * (1.0 - (current_wave * 0.02))
	spawn_delay = max(0.2, spawn_delay)
	
	spawn_wave(enemies_to_kill, spawn_delay, enemy_health_multiplier, enemy_speed_multiplier)

func _on_wave_timer_timeout():
	var enemies_remaining = get_tree().get_nodes_in_group("enemies").size()
	
	if enemies_remaining == 0 and enemies_spawned >= enemies_to_kill:
		end_wave()
		if has_node("WaveTimer"):
			$WaveTimer.queue_free()

func end_wave():
	wave_in_progress = false
	
	var wave_reward = 100 + (current_wave * 20)
	player_money += wave_reward
	update_money_ui()
	
	if $UI/HUD/BuildUI.has_node("SpawnButton"):
		$UI/HUD/BuildUI/SpawnButton.disabled = false
		$UI/HUD/BuildUI/SpawnButton.modulate = Color(1, 1, 1, 1)
		if $UI/HUD/BuildUI/SpawnButton.has_node("Image") and $UI/HUD/BuildUI/SpawnButton/Image.has_node("Label"):
			$UI/HUD/BuildUI/SpawnButton/Image/Label.text = "START\nWAVE " + str(current_wave + 1)
	
	var wave_completed_scene = load("res://scenes/wave_completed.tscn")
	var wave_completed = wave_completed_scene.instantiate()
	wave_completed.set_wave_info(current_wave, wave_reward)
	wave_completed.position = Vector2(get_viewport_rect().size.x / 2.0 - 100, get_viewport_rect().size.y / 2.0 - 50)
	$UI/HUD.add_child(wave_completed)

func spawn_wave(num_enemies = wave_size, delay = wave_delay, health_mult = 1.0, speed_mult = 1.0):
	for i in range(num_enemies):
		var timer = get_tree().create_timer(i * delay)
		timer.timeout.connect(func(): 
			spawn_enemy(health_mult, speed_mult)
			enemies_spawned += 1
		)

func spawn_enemy(health_mult = 1.0, speed_mult = 1.0):
	var enemy = enemy_scene.instantiate()
	var map_node = $Map
	var path = map_node.get_enemy_path()
	
	var path_follow = PathFollow2D.new()
	path.add_child(path_follow)
	
	enemy.path = path
	enemy.path_follow = path_follow
	
	enemy.max_health = round(enemy.max_health * health_mult)
	enemy.speed = enemy.speed * speed_mult
	
	enemy.connect("enemy_died", Callable(self, "_on_enemy_died"))
	enemy.connect("enemy_escaped", Callable(self, "_on_enemy_escaped"))
	
	enemy.add_to_group("enemies")
	
	add_child(enemy)

func _on_enemy_died():
	player_money += enemy_reward
	update_money_ui()

func _on_enemy_escaped():
	player_lives -= 1
	update_lives_ui()

	if player_lives <= 0:
		game_over()

func game_over():
	get_tree().paused = true
	
	var game_over_screen_scene = load("res://scenes/game_over_screen.tscn")
	var game_over_screen = game_over_screen_scene.instantiate()
	game_over_screen.set_wave_count(current_wave)
	game_over_screen.connect("restart_pressed", Callable(self, "_on_restart_pressed"))
	game_over_screen.connect("main_menu_pressed", Callable(self, "_on_main_menu_pressed"))
	
	$UI.add_child(game_over_screen)
	$AudioStreamPlayer.volume_db = -20.0

func _on_restart_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_main_menu_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/scene_handler.tscn")

func pause_music():
	$AudioStreamPlayer.stream_paused = true

func resume_music():
	$AudioStreamPlayer.stream_paused = false

func stop_music():
	$AudioStreamPlayer.stop()
