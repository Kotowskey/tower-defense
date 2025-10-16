extends Node

var map_selector: Control = null
var settings_menu: Control = null

func _ready():
	call_deferred("setup_difficulty_manager")
	call_deferred("setup_settings_manager")
	
	var timer = get_tree().create_timer(0.1)
	timer.timeout.connect(func(): connect_menu_buttons())

func setup_difficulty_manager():
	if not get_node_or_null("/root/DifficultyManager"):
		var diff_manager = load("res://scripts/managers/difficulty_manager.gd").new()
		diff_manager.name = "DifficultyManager"
		get_node("/root").add_child(diff_manager)
	var dm = get_node("/root/DifficultyManager")
	if not dm.has_meta("selected_map_path"):
		dm.set_meta("selected_map_path", "res://scenes/map.tscn")

func setup_settings_manager():
	if not get_node_or_null("/root/SettingsManager"):
		var settings_manager = load("res://scripts/managers/settings_manager.gd").new()
		settings_manager.name = "SettingsManager"
		get_node("/root").add_child(settings_manager)

func connect_menu_buttons():
	if has_node("Menu/MarginContainer/VBoxContainer/NEW GAME"):
		get_node("Menu/MarginContainer/VBoxContainer/NEW GAME").connect("pressed", Callable(self, "on_new_game_pressed"))
	
	if has_node("Menu/MarginContainer/VBoxContainer/QUIT"):
		get_node("Menu/MarginContainer/VBoxContainer/QUIT").connect("pressed", Callable(self, "on_quit_pressed"))
	
	if has_node("Menu/MarginContainer/VBoxContainer/SETTINGS"):
		get_node("Menu/MarginContainer/VBoxContainer/SETTINGS").connect("pressed", Callable(self, "on_settings_pressed"))
	
	if has_node("DifficultyMenu"):
		$DifficultyMenu.connect("difficulty_selected", Callable(self, "on_difficulty_selected"))
		$DifficultyMenu.connect("back_pressed", Callable(self, "on_diff_back_pressed"))
		
		$DifficultyMenu.hide()
	
func on_new_game_pressed():
	if has_node("Menu"):
		$Menu.hide()
	
	if has_node("DifficultyMenu"):
		$DifficultyMenu.show()
	else:
		open_map_selector()

func on_settings_pressed():
	if has_node("Menu"):
		$Menu.hide()
	
	if settings_menu and is_instance_valid(settings_menu):
		settings_menu.queue_free()
	
	var settings_scene = load("res://scenes/settings_menu.tscn")
	settings_menu = settings_scene.instantiate()
	settings_menu.connect("back_pressed", Callable(self, "on_settings_back_pressed"))
	add_child(settings_menu)

func on_settings_back_pressed():
	if settings_menu and is_instance_valid(settings_menu):
		settings_menu.queue_free()
		settings_menu = null
	
	if has_node("Menu"):
		$Menu.show()

func on_quit_pressed():
	get_tree().quit()

func on_difficulty_selected(difficulty):
	if has_node("/root/DifficultyManager"):
		get_node("/root/DifficultyManager").set_difficulty(difficulty)
	open_map_selector()

func on_diff_back_pressed():
	if has_node("DifficultyMenu"):
		$DifficultyMenu.hide()
	if has_node("Menu"):
		$Menu.show()

func open_map_selector():
	if has_node("DifficultyMenu"):
		$DifficultyMenu.hide()
	if map_selector and is_instance_valid(map_selector):
		map_selector.queue_free()
	
	var map_selector_scene = load("res://scenes/map_selector.tscn")
	map_selector = map_selector_scene.instantiate()
	map_selector.connect("map_selected", Callable(self, "_on_map_selected"))
	map_selector.connect("back_pressed", Callable(self, "_on_map_back_pressed"))
	add_child(map_selector)

func _on_map_selected(map_data):
	if has_node("/root/DifficultyManager"):
		get_node("/root/DifficultyManager").set_meta("selected_map_path", map_data.map_path)
	
	if map_selector and is_instance_valid(map_selector):
		map_selector.queue_free()
		map_selector = null
	
	start_game()

func _on_map_back_pressed():
	if map_selector and is_instance_valid(map_selector):
		map_selector.queue_free()
		map_selector = null
	if has_node("DifficultyMenu"):
		$DifficultyMenu.show()

func start_game():
	if has_node("DifficultyMenu"):
		$DifficultyMenu.queue_free()
	if has_node("Menu"):
		$Menu.queue_free()
	var game_scene = load("res://scenes/game_scene.tscn").instantiate()
	if has_node("/root/DifficultyManager"):
		var diff_manager = get_node("/root/DifficultyManager")
		game_scene.player_money = int(game_scene.player_money * diff_manager.get_difficulty_multiplier("player_money"))
		game_scene.enemy_reward = int(game_scene.enemy_reward * diff_manager.get_difficulty_multiplier("enemy_reward"))
	add_child(game_scene)
