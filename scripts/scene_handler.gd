extends Node

func _ready():
	get_node("Menu/MarginContainer/VBoxContainer/NEW GAME").connect("pressed", Callable(self, "on_new_game_pressed"))
	get_node("Menu/MarginContainer/VBoxContainer/QUIT").connect("pressed", Callable(self, "on_quit_pressed"))
	
func on_new_game_pressed():
	get_node("Menu").queue_free()
	var game_scene = load("res://scenes/game_scene.tscn").instantiate()
	add_child(game_scene)

func on_quit_pressed():
	get_tree().quit()
