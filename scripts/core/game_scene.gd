extends Node2D

@export var tower_scene: PackedScene = preload("res://scenes/tower.tscn")
@export var enemy_scene: PackedScene = preload("res://scenes/enemy.tscn")
@export var boss_enemy_scene: PackedScene = preload("res://scenes/boss_enemy.tscn")
@export var player_money: int = 500
@export var player_lives: int = 10
@export var tower_cost: int = 100
@export var enemy_reward: int = 25
@export var wave_size: int = 5
@export var wave_delay: float = 1.0

var game_state
var tower_manager
var wave_manager
var ui_manager
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
	game_state.set_initial_values(player_money, player_lives, enemy_reward)
	game_state.setup_enemy_rewards()  
	
	tower_manager = load("res://scripts/managers/tower_manager.gd").new(self, tower_scene, game_state)
	add_child(tower_manager)
	
	wave_manager = load("res://scripts/managers/wave_manager.gd").new(self, enemy_scene, boss_enemy_scene, game_state, wave_size, wave_delay)
	add_child(wave_manager)
	wave_manager.setup_map($Map)
	
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
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if tower_manager.is_in_building_mode():
				var mouse_pos = get_global_mouse_position()
				var placed = tower_manager.place_tower(mouse_pos)
				if not placed and tower_manager.is_valid_position == false:
					if has_node("InvalidPlacementSound"):
						$InvalidPlacementSound.play()
			else:
				var mouse_pos = get_global_mouse_position()
				tower_manager.select_tower_at_position(mouse_pos)
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			tower_manager.cancel_building()
			tower_manager.deselect_tower()

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"): 
		ui_manager.toggle_pause_menu()

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
