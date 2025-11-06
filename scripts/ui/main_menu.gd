extends Control

func _ready():
	$MainMenuSoundtrack.play()
	
	if has_node("MarginContainer/VBoxContainer/NEW GAME"):
		$"MarginContainer/VBoxContainer/NEW GAME".pressed.connect(_on_new_game_pressed)
	
	if has_node("MarginContainer/VBoxContainer/UPGRADES"):
		$"MarginContainer/VBoxContainer/UPGRADES".pressed.connect(_on_upgrades_pressed)
	
	if has_node("MarginContainer/VBoxContainer/SETTINGS"):
		$"MarginContainer/VBoxContainer/SETTINGS".pressed.connect(_on_settings_pressed)
	
	if has_node("MarginContainer/VBoxContainer/QUIT"):
		$"MarginContainer/VBoxContainer/QUIT".pressed.connect(_on_quit_pressed)

func _on_new_game_pressed():
	get_tree().change_scene_to_file("res://scenes/difficulty_menu.tscn")

func _on_upgrades_pressed():
	get_tree().change_scene_to_file("res://scenes/upgrade_tree_menu.tscn")

func _on_settings_pressed():
	get_tree().change_scene_to_file("res://scenes/settings_menu.tscn")

func _on_quit_pressed():
	get_tree().quit()
