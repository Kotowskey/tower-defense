extends Node2D

@export var tower_scene: PackedScene = preload("res://scenes/tower.tscn")
@export var enemy_scene: PackedScene = preload("res://scenes/enemy.tscn")
@export var boss_enemy_scene: PackedScene = preload("res://scenes/boss_enemy.tscn")

var game_state
var tower_manager
var ai_tower_manager
var player_enemy_manager
var settings_manager

func _ready():
	if not get_node_or_null("/root/SettingsManager"):
		settings_manager = load("res://scripts/managers/settings_manager.gd").new()
		settings_manager.name = "SettingsManager"
		get_node("/root").add_child(settings_manager)
	else:
		settings_manager = get_node("/root/SettingsManager")
	
	var selected_map_path := ""
	if has_node("/root/DifficultyManager"):
		selected_map_path = str(get_node("/root/DifficultyManager").get_meta("selected_map_path", ""))
	var default_map_path := "res://scenes/map.tscn"
	if selected_map_path != "" and selected_map_path != default_map_path:
		if has_node("Map"):
			$Map.free()
		var map_packed := load(selected_map_path)
		if map_packed:
			var new_map = map_packed.instantiate()
			new_map.name = "Map"
			add_child(new_map)
	
	game_state = load("res://scripts/managers/game_state.gd").new()
	add_child(game_state)
	game_state.set_initial_values(100, 10, 15)
	
	tower_manager = load("res://scripts/managers/tower_manager.gd").new(self, tower_scene, game_state)
	add_child(tower_manager)
	
	ai_tower_manager = load("res://scripts/managers/ai_tower_manager.gd").new(self, tower_manager, game_state)
	ai_tower_manager.name = "AITowerManager"
	add_child(ai_tower_manager)
	ai_tower_manager.setup_map($Map)
	
	player_enemy_manager = load("res://scripts/managers/player_enemy_manager.gd").new(self, enemy_scene, boss_enemy_scene, game_state)
	player_enemy_manager.name = "PlayerEnemyManager"
	add_child(player_enemy_manager)
	player_enemy_manager.setup_map($Map)
	
	player_enemy_manager.connect("enemy_spawned", Callable(self, "_on_enemy_spawned"))
	player_enemy_manager.connect("wave_completed", Callable(self, "_on_wave_completed"))
	
	_setup_ui()
	
	_connect_pause_menu_buttons()
	
	if has_node("AudioStreamPlayer"):
		$AudioStreamPlayer.play()
	
	set_process_input(true)
	print("Tower Rush mode initialized!")
	print("AI strategic positions: ", ai_tower_manager.strategic_positions.size())

func _connect_pause_menu_buttons():
	if has_node("UI/PauseMenu/VBoxContainer/ResumeButton"):
		$UI/PauseMenu/VBoxContainer/ResumeButton.connect("pressed", Callable(self, "_on_resume_pressed"))
	
	if has_node("UI/PauseMenu/VBoxContainer/RestartButton"):
		$UI/PauseMenu/VBoxContainer/RestartButton.connect("pressed", Callable(self, "_on_restart_pressed"))
	
	if has_node("UI/PauseMenu/VBoxContainer/MainMenuButton"):
		$UI/PauseMenu/VBoxContainer/MainMenuButton.connect("pressed", Callable(self, "_on_main_menu_pressed"))

func _setup_ui():
	if has_node("UI/HUD"):
		var hud = $UI/HUD
		
		_update_ui()
		
		_setup_spawn_buttons()

func _setup_spawn_buttons():
	if not has_node("UI/HUD/SpawnPanel"):
		var spawn_panel = VBoxContainer.new()
		spawn_panel.name = "SpawnPanel"
		spawn_panel.position = Vector2(20, 100)
		spawn_panel.add_theme_constant_override("separation", 10)
		$UI/HUD.add_child(spawn_panel)
		
		var title = Label.new()
		title.text = "SPAWN ENEMIES"
		title.add_theme_font_size_override("font_size", 20)
		spawn_panel.add_child(title)
		
		var basic_btn = Button.new()
		basic_btn.text = "Basic Enemy (10$)"
		basic_btn.name = "BasicEnemyButton"
		basic_btn.custom_minimum_size = Vector2(150, 40)
		basic_btn.connect("pressed", Callable(self, "_on_spawn_basic_enemy"))
		spawn_panel.add_child(basic_btn)
		
		var fast_btn = Button.new()
		fast_btn.text = "Fast Enemy (15$)"
		fast_btn.name = "FastEnemyButton"
		fast_btn.custom_minimum_size = Vector2(150, 40)
		fast_btn.connect("pressed", Callable(self, "_on_spawn_fast_enemy"))
		spawn_panel.add_child(fast_btn)
		
		var tank_btn = Button.new()
		tank_btn.text = "Tank Enemy (25$)"
		tank_btn.name = "TankEnemyButton"
		tank_btn.custom_minimum_size = Vector2(150, 40)
		tank_btn.connect("pressed", Callable(self, "_on_spawn_tank_enemy"))
		spawn_panel.add_child(tank_btn)
		
		var queue_label = Label.new()
		queue_label.name = "QueueLabel"
		queue_label.text = "Queue: 0"
		spawn_panel.add_child(queue_label)
		
		var alive_label = Label.new()
		alive_label.name = "AliveLabel"
		alive_label.text = "Active: 0"
		spawn_panel.add_child(alive_label)

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		_toggle_pause_menu()
		return
	
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_1:
			_on_spawn_basic_enemy()
		elif event.keycode == KEY_2:
			_on_spawn_fast_enemy()
		elif event.keycode == KEY_3:
			_on_spawn_tank_enemy()

func _on_spawn_basic_enemy():
	if player_enemy_manager.queue_enemy(0):
		_update_ui()

func _on_spawn_fast_enemy():
	if player_enemy_manager.queue_enemy(1):
		_update_ui()

func _on_spawn_tank_enemy():
	if player_enemy_manager.queue_enemy(2):
		_update_ui()

func _on_enemy_spawned():
	ai_tower_manager.add_money(15)

func _on_ai_life_lost():
	if has_node("UI/HUD"):
		var flash = ColorRect.new()
		flash.color = Color(1, 0, 0, 0.3)
		flash.set_anchors_preset(Control.PRESET_FULL_RECT)
		$UI.add_child(flash)
		
		var tween = create_tween()
		tween.tween_property(flash, "modulate:a", 0.0, 0.5)
		tween.tween_callback(flash.queue_free)

func _on_wave_completed(wave_num: int, reward: int):
	print("UI: Wave completed notification - Wave: ", wave_num, " Reward: ", reward)
	
	var notification = PanelContainer.new()
	notification.set_anchors_preset(Control.PRESET_CENTER)
	notification.offset_left = -200
	notification.offset_top = -100
	notification.offset_right = 200
	notification.offset_bottom = 100
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	
	var title = Label.new()
	title.text = "WAVE " + str(wave_num - 1) + " COMPLETED!"
	title.add_theme_font_size_override("font_size", 28)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_color_override("font_color", Color(0, 1, 0))
	
	var reward_label = Label.new()
	reward_label.text = "Reward: $" + str(reward)
	reward_label.add_theme_font_size_override("font_size", 20)
	reward_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	var next_wave = Label.new()
	next_wave.text = "Next Wave: " + str(wave_num)
	next_wave.add_theme_font_size_override("font_size", 18)
	next_wave.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	vbox.add_child(title)
	vbox.add_child(reward_label)
	vbox.add_child(next_wave)
	notification.add_child(vbox)
	
	$UI.add_child(notification)
	
	await get_tree().create_timer(1.8).timeout
	if is_instance_valid(notification):
		notification.queue_free()

func _update_ui():
	if has_node("UI/HUD/TopBar/VBoxContainer/MoneyLabel"):
		$UI/HUD/TopBar/VBoxContainer/MoneyLabel.text = "Money: " + str(player_enemy_manager.get_money())
	
	if has_node("UI/HUD/SpawnPanel/QueueLabel"):
		$UI/HUD/SpawnPanel/QueueLabel.text = "Queue: " + str(player_enemy_manager.get_queue_size())
	
	if has_node("UI/HUD/SpawnPanel/AliveLabel"):
		$UI/HUD/SpawnPanel/AliveLabel.text = "Active: " + str(player_enemy_manager.get_enemies_alive())
	
	if has_node("UI/HUD/TopBar/VBoxContainer/LivesLabel"):
		$UI/HUD/TopBar/VBoxContainer/LivesLabel.text = "AI Lives: " + str(ai_tower_manager.get_lives())
	
	if has_node("UI/HUD/TopBar/VBoxContainer/WaveLabel"):
		var wave_status = "Active" if player_enemy_manager.wave_active else "Waiting"
		$UI/HUD/TopBar/VBoxContainer/WaveLabel.text = "Wave: " + str(player_enemy_manager.get_current_wave()) + " (" + wave_status + ")"
	
	if has_node("UI/HUD/InfoPanel/VBoxContainer/InfoTitle"):
		var info_title = $UI/HUD/InfoPanel/VBoxContainer/InfoTitle
		var tower_count = ai_tower_manager.placed_towers.size()
		info_title.text = "AI: $" + str(ai_tower_manager.get_money()) + " | Towers: " + str(tower_count) + "/" + str(ai_tower_manager.max_towers)

func _process(_delta):
	_update_ui()

func _toggle_pause_menu():
	get_tree().paused = !get_tree().paused
	if has_node("UI/PauseMenu"):
		$UI/PauseMenu.visible = get_tree().paused

func _on_resume_pressed():
	get_tree().paused = false
	if has_node("UI/PauseMenu"):
		$UI/PauseMenu.visible = false

func _on_restart_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_main_menu_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/scene_handler.tscn")

func pause_music():
	if has_node("AudioStreamPlayer"):
		$AudioStreamPlayer.stream_paused = true

func resume_music():
	if has_node("AudioStreamPlayer"):
		$AudioStreamPlayer.stream_paused = false

func stop_music():
	if has_node("AudioStreamPlayer"):
		$AudioStreamPlayer.stop()

func _on_player_victory():
	print("Player Victory!")
	get_tree().paused = true
	
	var victory_screen = ColorRect.new()
	victory_screen.color = Color(0, 0.5, 0, 0.8)
	victory_screen.set_anchors_preset(Control.PRESET_FULL_RECT)
	
	var vbox = VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_CENTER)
	vbox.offset_left = -200
	vbox.offset_top = -150
	vbox.offset_right = 200
	vbox.offset_bottom = 150
	vbox.add_theme_constant_override("separation", 20)
	
	var title = Label.new()
	title.text = "VICTORY!"
	title.add_theme_font_size_override("font_size", 48)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_color_override("font_color", Color(1, 1, 0))
	
	var message = Label.new()
	message.text = "You destroyed all AI defenses!\nWaves completed: " + str(player_enemy_manager.get_current_wave())
	message.add_theme_font_size_override("font_size", 20)
	message.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	
	var restart_btn = Button.new()
	restart_btn.text = "Restart"
	restart_btn.custom_minimum_size = Vector2(200, 50)
	restart_btn.add_theme_font_size_override("font_size", 18)
	restart_btn.connect("pressed", Callable(self, "_on_restart_pressed"))
	
	var menu_btn = Button.new()
	menu_btn.text = "Main Menu"
	menu_btn.custom_minimum_size = Vector2(200, 50)
	menu_btn.add_theme_font_size_override("font_size", 18)
	menu_btn.connect("pressed", Callable(self, "_on_main_menu_pressed"))
	
	vbox.add_child(title)
	vbox.add_child(message)
	vbox.add_child(restart_btn)
	vbox.add_child(menu_btn)
	
	victory_screen.add_child(vbox)
	$UI.add_child(victory_screen)
	
	stop_music()
