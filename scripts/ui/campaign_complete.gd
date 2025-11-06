extends Control

signal main_menu_pressed

func _ready():
	$Panel/MarginContainer/VBoxContainer/MainMenuButton.connect("pressed", Callable(self, "_on_main_menu_pressed"))

func _on_main_menu_pressed():
	emit_signal("main_menu_pressed")
