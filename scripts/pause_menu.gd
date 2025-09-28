extends Control

signal resume_pressed
signal settings_pressed
signal main_menu_pressed

func _ready():
	$MenuPanel/VBoxContainer/ResumeButton.connect("pressed", Callable(self, "_on_resume_button_pressed"))
	$MenuPanel/VBoxContainer/SettingsButton.connect("pressed", Callable(self, "_on_settings_button_pressed"))
	$MenuPanel/VBoxContainer/MainMenuButton.connect("pressed", Callable(self, "_on_main_menu_button_pressed"))

func _on_resume_button_pressed():
	emit_signal("resume_pressed")

func _on_settings_button_pressed():
	emit_signal("settings_pressed")

func _on_main_menu_button_pressed():
	emit_signal("main_menu_pressed")
	get_parent().get_parent().stop_music()
