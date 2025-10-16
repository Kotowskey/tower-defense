extends Node

func _ready():
	$MainMenuSoundtrack.play()
	
	if has_node("MarginContainer/VBoxContainer/TALENTS"):
		$MarginContainer/VBoxContainer/TALENTS.connect("pressed", Callable(self, "_on_talents_button_pressed"))

func _on_talents_button_pressed():
	var talent_tree_scene = load("res://scenes/talent_tree_ui.tscn")
	var talent_tree = talent_tree_scene.instantiate()
	add_child(talent_tree)
