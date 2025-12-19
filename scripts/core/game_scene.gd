extends Node2D

@export var tower_scene: PackedScene = preload("res://scenes/tower.tscn")
@export var enemy_scene: PackedScene = preload("res://scenes/enemy.tscn")
@export var boss_enemy_scene: PackedScene = preload("res://scenes/boss_enemy.tscn")
@export var player_money: int = 250
@export var player_lives: int = 10
@export var tower_cost: int = 100
@export var enemy_reward: int = 15
@export var wave_size: int = 3
@export var wave_delay: float = 1.0

var game_state
var tower_manager
var wave_manager
var ui_manager
var settings_manager
var game_mode_manager
var current_campaign_level: CampaignLevel = null

func _ready():
	if not get_node_or_null("/root/SettingsManager"):
		settings_manager = load("res://scripts/managers/settings_manager.gd").new()
		settings_manager.name = "SettingsManager"
		get_node("/root").add_child(settings_manager)
	else:
		settings_manager = get_node("/root/SettingsManager")
	
	if not get_node_or_null("/root/GameModeManager"):
		game_mode_manager = load("res://scripts/managers/game_mode_manager.gd").new()
		game_mode_manager.name = "GameModeManager"
		get_node("/root").add_child(game_mode_manager)
	else:
		game_mode_manager = get_node("/root/GameModeManager")
	
	if not get_node_or_null("/root/UpgradeCurrencyManager"):
		var upgrade_currency_manager = load("res://scripts/managers/upgrade_currency_manager.gd").new()
		upgrade_currency_manager.name = "UpgradeCurrencyManager"
		get_node("/root").add_child(upgrade_currency_manager)
	
	if not get_node_or_null("/root/TowerUpgradeTree"):
		var tower_upgrade_tree = load("res://scripts/managers/tower_upgrade_tree.gd").new()
		tower_upgrade_tree.name = "TowerUpgradeTree"
		get_node("/root").add_child(tower_upgrade_tree)
	
	setup_campaign_level()
	
	var selected_map_path := ""
	if has_node("/root/DifficultyManager"):
		selected_map_path = str(get_node("/root/DifficultyManager").get_meta("selected_map_path", ""))
	var default_map_path := "res://scenes/map.tscn"
	
	if game_mode_manager.is_campaign() and current_campaign_level:
		selected_map_path = current_campaign_level.map_path
	
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
	game_state.set_initial_values(player_money, player_lives, enemy_reward)
	game_state.setup_enemy_rewards()
	game_state.connect("game_over", Callable(self, "_on_game_over"))
	
	tower_manager = load("res://scripts/managers/tower_manager.gd").new(self, tower_scene, game_state)
	add_child(tower_manager)
	
	wave_manager = load("res://scripts/managers/wave_manager.gd").new(self, enemy_scene, boss_enemy_scene, game_state, wave_size, wave_delay)
	add_child(wave_manager)
	wave_manager.setup_map($Map)
	wave_manager.connect("level_completed", Callable(self, "_on_level_completed"))
	
	if game_mode_manager.is_campaign() and current_campaign_level:
		wave_manager.set_max_waves(current_campaign_level.max_waves)
		wave_manager.set_campaign_difficulty_multiplier(current_campaign_level.difficulty_multiplier)
	
	ui_manager = load("res://scripts/ui/ui_manager.gd").new(self, game_state, tower_manager, wave_manager)
	add_child(ui_manager)
	
	var info_display_scene = load("res://scenes/tower_info_display.tscn")
	var tower_info_display = info_display_scene.instantiate()
	tower_info_display.visible = false
	$UI/HUD.add_child(tower_info_display)
	tower_manager.setup_tower_info_display(tower_info_display)
	
	ui_manager.connect_ui_buttons()
	ui_manager.update_money_ui()
	ui_manager.update_lives_ui()
	ui_manager.update_wave_ui()
	ui_manager.update_upgrade_ui()
	
	if $UI/HUD/BuildPanel/BuildUI.has_node("SpawnButton") and $UI/HUD/BuildPanel/BuildUI/SpawnButton.has_node("Image") and $UI/HUD/BuildPanel/BuildUI/SpawnButton/Image.has_node("Label"):
		$UI/HUD/BuildPanel/BuildUI/SpawnButton/Image/Label.text = "START\nWAVE 1"

	$AudioStreamPlayer.play()
	set_process_input(true)

func _input(event):
	if event.is_action_pressed("toggle_build_menu"):
		ui_manager.toggle_build_menu()
		get_viewport().set_input_as_handled()
		return
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if tower_manager.is_in_building_mode():
				var mouse_pos = get_global_mouse_position()
				var placed = tower_manager.place_tower(mouse_pos)
				if not placed and tower_manager.is_valid_position == false:
					if has_node("InvalidPlacementSound"):
						$InvalidPlacementSound.play()
				else:
					if placed:
						get_viewport().gui_release_focus()
			else:
				var mouse_pos = get_global_mouse_position()
				tower_manager.select_tower_at_position(mouse_pos)
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			tower_manager.cancel_building()
			tower_manager.deselect_tower()

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"): 
		if tower_manager.is_in_building_mode():
			tower_manager.cancel_building()
		else:
			ui_manager.toggle_pause_menu()

func _on_restart_pressed():
	get_tree().paused = false
	var root_scene = get_tree().current_scene
	if root_scene and root_scene != self and root_scene.has_method("start_game"):
		root_scene.start_game()
	else:
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

func setup_campaign_level():
	if game_mode_manager and game_mode_manager.is_campaign():
		var level_number = game_mode_manager.get_campaign_level()
		current_campaign_level = CampaignLevel.get_level(level_number)
		
		if current_campaign_level:
			player_money = current_campaign_level.starting_money + game_mode_manager.get_campaign_bonus()
			player_lives = current_campaign_level.starting_lives
			game_mode_manager.clear_campaign_bonus()

func _on_level_completed():
	if game_mode_manager and game_mode_manager.is_campaign():
		stop_music()
		get_tree().paused = true
		
		var is_final = game_mode_manager.is_final_level()
		
		if is_final:
			show_campaign_complete()
		else:
			show_level_complete()

func show_level_complete():
	var level_complete_scene = load("res://scenes/level_complete.tscn")
	if level_complete_scene:
		var level_complete = level_complete_scene.instantiate()
		var bonus_money = game_state.player_money
		level_complete.set_level_info(game_mode_manager.get_campaign_level(), bonus_money)
		print("Connecting next_level_pressed signal...")
		level_complete.connect("next_level_pressed", Callable(self, "_on_next_level"))
		level_complete.connect("main_menu_pressed", Callable(self, "_on_main_menu_from_victory"))
		print("Signals connected!")
		$UI/HUD.add_child(level_complete)

func show_campaign_complete():
	var campaign_complete_scene = load("res://scenes/campaign_complete.tscn")
	if campaign_complete_scene:
		var campaign_complete = campaign_complete_scene.instantiate()
		campaign_complete.connect("main_menu_pressed", Callable(self, "_on_main_menu_from_victory"))
		$UI/HUD.add_child(campaign_complete)

func _on_next_level():
	print("_on_next_level called!")
	if game_mode_manager:
		var bonus_money = game_state.player_money
		game_mode_manager.add_campaign_bonus(bonus_money)
		
		var old_level = game_mode_manager.get_campaign_level()
		game_mode_manager.next_campaign_level()
		game_mode_manager.save_progress()
		var new_level = game_mode_manager.get_campaign_level()
		print("Level changed from ", old_level, " to ", new_level)
		print("Bonus money carried over: ", bonus_money)
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_main_menu_from_victory():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/scene_handler.tscn")

func _on_game_over():
	pass
