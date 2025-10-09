extends Node

var map_selector: Control = null

func _ready():
	call_deferred("setup_difficulty_manager")
	
	var timer = get_tree().create_timer(0.1)
	timer.timeout.connect(func(): connect_menu_buttons())

func setup_difficulty_manager():
	if not get_node_or_null("/root/DifficultyManager"):
		var diff_manager = load("res://scripts/difficulty_manager.gd").new()
		diff_manager.name = "DifficultyManager"
		get_node("/root").add_child(diff_manager)
	var dm = get_node("/root/DifficultyManager")
	if not dm.has_meta("selected_map_path"):
		dm.set_meta("selected_map_path", "res://scenes/map.tscn")

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
	pass

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

	var panel := Panel.new()
	panel.name = "MapSelector"
	panel.set_anchors_preset(Control.PRESET_CENTER, true)
	panel.custom_minimum_size = Vector2(320, 220)

	var v := VBoxContainer.new()
	v.anchor_right = 1.0
	v.anchor_bottom = 1.0
	v.offset_left = 20
	v.offset_top = 20
	v.offset_right = -20
	v.offset_bottom = -20
	v.add_theme_constant_override("separation", 16)
	panel.add_child(v)

	var lbl := Label.new()
	lbl.text = "SELECT MAP"
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(lbl)

	var b1 := Button.new()
	b1.text = "MAP 1 (map.tscn)"
	b1.pressed.connect(Callable(self, "_on_map_chosen").bind("res://scenes/map.tscn"))
	v.add_child(b1)

	var b2 := Button.new()
	b2.text = "MAP 2 (map2.tscn)"
	b2.pressed.connect(Callable(self, "_on_map_chosen").bind("res://scenes/map2.tscn"))
	v.add_child(b2)

	var back := Button.new()
	back.text = "BACK"
	back.pressed.connect(Callable(self, "_on_map_back_pressed"))
	v.add_child(back)

	add_child(panel)
	map_selector = panel

func _on_map_chosen(path: String):
	if has_node("/root/DifficultyManager"):
		get_node("/root/DifficultyManager").set_meta("selected_map_path", path)
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
