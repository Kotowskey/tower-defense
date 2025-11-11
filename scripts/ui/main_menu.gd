extends Node

func _ready():
	$MainMenuSoundtrack.play()

func open_upgrade_menu():
	var upgrade_menu_scene = load("res://scenes/tower_upgrade_menu.tscn")
	var upgrade_menu = upgrade_menu_scene.instantiate()
	add_child(upgrade_menu)
	upgrade_menu.connect("closed", Callable(self, "_on_upgrade_menu_closed"))

func _on_upgrade_menu_closed():
	pass
