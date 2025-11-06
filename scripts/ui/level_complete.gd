extends Control

signal next_level_pressed
signal main_menu_pressed

func _ready():
	$Panel/MarginContainer/VBoxContainer/NextButton.connect("pressed", Callable(self, "_on_next_pressed"))
	$Panel/MarginContainer/VBoxContainer/MainMenuButton.connect("pressed", Callable(self, "_on_main_menu_pressed"))

func set_level_info(level_number: int):
	$Panel/MarginContainer/VBoxContainer/LevelInfo.text = "Level " + str(level_number) + " Complete!"

func _on_next_pressed():
	print("Next level button pressed!")
	emit_signal("next_level_pressed")

func _on_main_menu_pressed():
	print("Main menu button pressed from level complete!")
	emit_signal("main_menu_pressed")
