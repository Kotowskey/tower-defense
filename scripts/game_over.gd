extends Control

signal restart_pressed
signal main_menu_pressed

func _ready():
	$VBoxContainer/RestartButton.connect("pressed", Callable(self, "_on_restart_pressed"))
	$VBoxContainer/MainMenuButton.connect("pressed", Callable(self, "_on_main_menu_pressed"))

func set_wave_count(count):
	$VBoxContainer/WavesLabel.text = "You lasted " + str(count) + " waves!"

func _on_restart_pressed():
	emit_signal("restart_pressed")

func _on_main_menu_pressed():
	emit_signal("main_menu_pressed")
