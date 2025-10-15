extends Control

signal restart_pressed
signal main_menu_pressed

func _ready():
	$VBoxContainer/RestartButton.connect("pressed", Callable(self, "_on_restart_button_pressed"))
	$VBoxContainer/MainMenuButton.connect("pressed", Callable(self, "_on_main_menu_button_pressed"))

func set_wave_count(wave):
	$VBoxContainer/WavesLabel.text = "You survived " + str(wave) + " waves!"

func _on_restart_button_pressed():
	emit_signal("restart_pressed")

func _on_main_menu_button_pressed():
	emit_signal("main_menu_pressed")
