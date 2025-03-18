extends Node

func _ready():
	get_node("Menu/MarginContainer/VBoxContainer/NEW GAME").connect("pressed", Callable(self, "on_new_game_pressed"))
	get_node("Menu/MarginContainer/VBoxContainer/QUIT").connect("pressed", Callable(self, "on_quit_pressed"))
	
func on_new_game_pressed():
	pass

func on_quit_pressed():
	get_tree().quit()
