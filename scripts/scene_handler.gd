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
	
	# Przyciski poziomu trudności - podłącz je tylko jeśli menu trudności istnieje
	if has_node("DifficultyMenu"):
		if has_node("DifficultyMenu/VBoxContainer/EASY"):
			get_node("DifficultyMenu/VBoxContainer/EASY").connect("pressed", Callable(self, "on_easy_pressed"))
		
		if has_node("DifficultyMenu/VBoxContainer/NORMAL"):
			get_node("DifficultyMenu/VBoxContainer/NORMAL").connect("pressed", Callable(self, "on_normal_pressed"))
		
		if has_node("DifficultyMenu/VBoxContainer/HARD"):
			get_node("DifficultyMenu/VBoxContainer/HARD").connect("pressed", Callable(self, "on_hard_pressed"))
		
		if has_node("DifficultyMenu/VBoxContainer/BACK"):
			get_node("DifficultyMenu/VBoxContainer/BACK").connect("pressed", Callable(self, "on_diff_back_pressed"))
		
		get_node("DifficultyMenu").hide()
	
func on_new_game_pressed():
	if has_node("Menu"):
		get_node("Menu").hide()
	
	if has_node("DifficultyMenu"):
		get_node("DifficultyMenu").show()
	else:
		start_game()

func on_settings_pressed():
	pass

func on_quit_pressed():
	get_tree().quit()

func on_easy_pressed():
	if has_node("/root/DifficultyManager"):
		get_node("/root/DifficultyManager").set_difficulty(0) # EASY
	start_game()

func on_normal_pressed():
	if has_node("/root/DifficultyManager"):
		get_node("/root/DifficultyManager").set_difficulty(1) # NORMAL
	start_game()

func on_hard_pressed():
	if has_node("/root/DifficultyManager"):
		get_node("/root/DifficultyManager").set_difficulty(2) # HARD
	start_game()

func on_diff_back_pressed():
	if has_node("DifficultyMenu"):
		get_node("DifficultyMenu").hide()
	
	if has_node("Menu"):
		get_node("Menu").show()

func start_game():
	# Usuń menu
	if has_node("DifficultyMenu"):
		get_node("DifficultyMenu").queue_free()
	
	if has_node("Menu"):
		get_node("Menu").queue_free()
	
	var game_scene = load("res://scenes/game_scene.tscn").instantiate()
	
	if has_node("/root/DifficultyManager"):
		var diff_manager = get_node("/root/DifficultyManager")
		game_scene.player_money = int(game_scene.player_money * diff_manager.get_difficulty_multiplier("player_money"))
		game_scene.enemy_reward = int(game_scene.enemy_reward * diff_manager.get_difficulty_multiplier("enemy_reward"))
	
	add_child(game_scene)
