extends Node

func _ready():
	call_deferred("setup_difficulty_manager")
	
	var timer = get_tree().create_timer(0.1)
	timer.timeout.connect(func(): connect_menu_buttons())

func setup_difficulty_manager():
	if not get_node_or_null("/root/DifficultyManager"):
		var diff_manager = load("res://scripts/difficulty_manager.gd").new()
		diff_manager.name = "DifficultyManager"
		get_node("/root").add_child(diff_manager)

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
		start_game()

func on_settings_pressed():
	pass

func on_quit_pressed():
	get_tree().quit()

func on_difficulty_selected(difficulty):
	if has_node("/root/DifficultyManager"):
		get_node("/root/DifficultyManager").set_difficulty(difficulty)
	start_game()

func on_diff_back_pressed():
	if has_node("DifficultyMenu"):
		$DifficultyMenu.hide()
	
	if has_node("Menu"):
		$Menu.show()

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
