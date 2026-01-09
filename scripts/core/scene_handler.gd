extends Node

var map_selector: Control = null
var settings_menu: Control = null
var game_mode_selector: Control = null
var campaign_level_selector: Control = null
var almanac: Control = null

func _ready():
	if not DifficultyManager.has_meta("selected_map_path"):
		DifficultyManager.set_meta("selected_map_path", "res://scenes/map.tscn")
	
	var timer = get_tree().create_timer(0.1)
	timer.timeout.connect(func(): 
		connect_menu_buttons()
		check_if_should_open_campaign_selector()
	)

func connect_menu_buttons():
	if has_node("Menu/MarginContainer/VBoxContainer/NEW GAME"):
		get_node("Menu/MarginContainer/VBoxContainer/NEW GAME").connect("pressed", Callable(self, "on_new_game_pressed"))
	
	if has_node("Menu/MarginContainer/VBoxContainer/QUIT"):
		get_node("Menu/MarginContainer/VBoxContainer/QUIT").connect("pressed", Callable(self, "on_quit_pressed"))
	
	if has_node("Menu/MarginContainer/VBoxContainer/SETTINGS"):
		get_node("Menu/MarginContainer/VBoxContainer/SETTINGS").connect("pressed", Callable(self, "on_settings_pressed"))
	
	if has_node("Menu/MarginContainer/VBoxContainer/UPGRADES"):
		get_node("Menu/MarginContainer/VBoxContainer/UPGRADES").connect("pressed", Callable(self, "on_upgrades_pressed"))
	
	if has_node("Menu/MarginContainer/VBoxContainer/ALMANAC"):
		get_node("Menu/MarginContainer/VBoxContainer/ALMANAC").connect("pressed", Callable(self, "on_almanac_pressed"))
	
	if has_node("DifficultyMenu"):
		$DifficultyMenu.connect("difficulty_selected", Callable(self, "on_difficulty_selected"))
		$DifficultyMenu.connect("back_pressed", Callable(self, "on_diff_back_pressed"))
		
		$DifficultyMenu.hide()

func check_if_should_open_campaign_selector():
	if GameModeManager.is_campaign():
		if has_node("Menu"):
			$Menu.hide()
		open_campaign_level_selector()
	
func on_new_game_pressed():
	if has_node("Menu"):
		$Menu.hide()
	
	open_game_mode_selector()

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

func on_upgrades_pressed():
	if has_node("Menu"):
		$Menu.hide()
	
	var upgrade_menu_scene = load("res://scenes/tower_upgrade_menu.tscn")
	var upgrade_menu = upgrade_menu_scene.instantiate()
	upgrade_menu.connect("closed", Callable(self, "on_upgrade_menu_closed"))
	add_child(upgrade_menu)

func on_upgrade_menu_closed():
	if has_node("Menu"):
		$Menu.show()

func on_almanac_pressed():
	if has_node("Menu"):
		$Menu.hide()
	
	if almanac and is_instance_valid(almanac):
		almanac.queue_free()
	
	var almanac_scene = load("res://scenes/almanac.tscn")
	almanac = almanac_scene.instantiate()
	almanac.connect("back_pressed", Callable(self, "on_almanac_back_pressed"))
	add_child(almanac)

func on_almanac_back_pressed():
	if almanac and is_instance_valid(almanac):
		almanac.queue_free()
		almanac = null
	
	if has_node("Menu"):
		$Menu.show()

func on_quit_pressed():
	get_tree().quit()

func on_difficulty_selected(difficulty):
	DifficultyManager.set_difficulty(difficulty)
	
	if GameModeManager.is_campaign():
		open_campaign_level_selector()
	else:
		open_map_selector()

func on_diff_back_pressed():
	if has_node("DifficultyMenu"):
		$DifficultyMenu.hide()
	open_game_mode_selector()

func open_game_mode_selector():
	if has_node("Menu"):
		$Menu.hide()
	if has_node("DifficultyMenu"):
		$DifficultyMenu.hide()
	
	if game_mode_selector and is_instance_valid(game_mode_selector):
		game_mode_selector.queue_free()
	
	var mode_selector_scene = load("res://scenes/game_mode_selector.tscn")
	game_mode_selector = mode_selector_scene.instantiate()
	game_mode_selector.connect("mode_selected", Callable(self, "_on_mode_selected"))
	game_mode_selector.connect("back_pressed", Callable(self, "_on_mode_back_pressed"))
	add_child(game_mode_selector)

func _on_mode_selected(mode: int):
	GameModeManager.set_mode(mode)
	if mode == 1:
		GameModeManager.reset_campaign()
	
	if game_mode_selector and is_instance_valid(game_mode_selector):
		game_mode_selector.queue_free()
		game_mode_selector = null
	
	if has_node("DifficultyMenu"):
		$DifficultyMenu.show()
	else:
		open_map_selector()

func _on_mode_back_pressed():
	if game_mode_selector and is_instance_valid(game_mode_selector):
		game_mode_selector.queue_free()
		game_mode_selector = null
	
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
	DifficultyManager.set_meta("selected_map_path", map_data.map_path)
	
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

func open_campaign_level_selector():
	if has_node("DifficultyMenu"):
		$DifficultyMenu.hide()
	
	if campaign_level_selector and is_instance_valid(campaign_level_selector):
		campaign_level_selector.queue_free()
	
	var level_selector_scene = load("res://scenes/campaign_level_selector.tscn")
	campaign_level_selector = level_selector_scene.instantiate()
	campaign_level_selector.connect("level_selected", Callable(self, "_on_campaign_level_selected"))
	campaign_level_selector.connect("back_pressed", Callable(self, "_on_campaign_level_back_pressed"))
	add_child(campaign_level_selector)

func _on_campaign_level_selected(level_number: int):
	GameModeManager.set_campaign_level(level_number)
	
	if campaign_level_selector and is_instance_valid(campaign_level_selector):
		campaign_level_selector.queue_free()
		campaign_level_selector = null
	
	start_game()

func _on_campaign_level_back_pressed():
	if campaign_level_selector and is_instance_valid(campaign_level_selector):
		campaign_level_selector.queue_free()
		campaign_level_selector = null
	
	if has_node("DifficultyMenu"):
		$DifficultyMenu.show()

func start_game():
	if has_node("GameScene"):
		var existing_game_scene = get_node("GameScene")
		existing_game_scene.name = "GameScene_Old"
		existing_game_scene.queue_free()
	if has_node("DifficultyMenu"):
		$DifficultyMenu.queue_free()
	if has_node("Menu"):
		$Menu.queue_free()
	var game_scene = load("res://scenes/game_scene.tscn").instantiate()
	game_scene.name = "GameScene"
	game_scene.player_money = int(game_scene.player_money * DifficultyManager.get_difficulty_multiplier("player_money"))
	game_scene.enemy_reward = int(game_scene.enemy_reward * DifficultyManager.get_difficulty_multiplier("enemy_reward"))
	add_child(game_scene)
