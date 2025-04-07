extends Control

func _ready():
    hide()
    $VBoxContainer/ResumeButton.connect("pressed", Callable(self, "_on_resume_pressed"))
    $VBoxContainer/SettingsButton.connect("pressed", Callable(self, "_on_settings_pressed"))
    $VBoxContainer/MainMenuButton.connect("pressed", Callable(self, "_on_main_menu_pressed"))

func _on_resume_pressed():
    get_tree().paused = false
    hide()
    get_parent().get_parent().resume_music()

func _on_settings_pressed():
    # Tu można dodać logikę ustawień
    pass

func _on_main_menu_pressed():
    get_tree().paused = false
    get_parent().get_parent().stop_music()
    # Powrót do menu głównego
    get_tree().change_scene_to_file("res://scenes/scene_handler.tscn")