extends Control

signal back_pressed

var settings_manager

func _ready():
	if not get_node_or_null("/root/SettingsManager"):
		settings_manager = load("res://scripts/managers/settings_manager.gd").new()
		settings_manager.name = "SettingsManager"
		get_node("/root").add_child(settings_manager)
	else:
		settings_manager = get_node("/root/SettingsManager")
	
	$Panel/VBoxContainer/MusicContainer/HBoxContainer/MusicSlider.connect("value_changed", Callable(self, "_on_music_slider_changed"))
	$Panel/VBoxContainer/SFXContainer/HBoxContainer/SFXSlider.connect("value_changed", Callable(self, "_on_sfx_slider_changed"))
	$Panel/VBoxContainer/BackButton.connect("pressed", Callable(self, "_on_back_pressed"))
	
	load_current_settings()

func load_current_settings():
	var music_percent = settings_manager.music_volume * 100.0
	var sfx_percent = settings_manager.sfx_volume * 100.0
	
	$Panel/VBoxContainer/MusicContainer/HBoxContainer/MusicSlider.value = music_percent
	$Panel/VBoxContainer/SFXContainer/HBoxContainer/SFXSlider.value = sfx_percent
	
	$Panel/VBoxContainer/MusicContainer/HBoxContainer/MusicValue.text = str(int(music_percent)) + "%"
	$Panel/VBoxContainer/SFXContainer/HBoxContainer/SFXValue.text = str(int(sfx_percent)) + "%"

func _on_music_slider_changed(value: float):
	var volume = value / 100.0
	settings_manager.set_music_volume(volume)
	$Panel/VBoxContainer/MusicContainer/HBoxContainer/MusicValue.text = str(int(value)) + "%"

func _on_sfx_slider_changed(value: float):
	var volume = value / 100.0
	settings_manager.set_sfx_volume(volume)
	$Panel/VBoxContainer/SFXContainer/HBoxContainer/SFXValue.text = str(int(value)) + "%"

func _on_back_pressed():
	emit_signal("back_pressed")
