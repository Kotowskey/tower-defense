extends Control

signal mode_selected(mode)
signal back_pressed

func _ready():
	if has_node("MarginContainer/VBoxContainer/ClassicButton"):
		$MarginContainer/VBoxContainer/ClassicButton.connect("pressed", Callable(self, "_on_classic_pressed"))
	
	if has_node("MarginContainer/VBoxContainer/TowerRushButton"):
		$MarginContainer/VBoxContainer/TowerRushButton.connect("pressed", Callable(self, "_on_tower_rush_pressed"))
	
	if has_node("MarginContainer/VBoxContainer/BackButton"):
		$MarginContainer/VBoxContainer/BackButton.connect("pressed", Callable(self, "_on_back_pressed"))

func _on_classic_pressed():
	emit_signal("mode_selected", 0) # Classic mode

func _on_tower_rush_pressed():
	emit_signal("mode_selected", 1) # Tower Rush mode

func _on_back_pressed():
	emit_signal("back_pressed")
