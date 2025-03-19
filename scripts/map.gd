extends Node2D

@onready var path = $Path2D

func _ready():
	pass

# Funkcja do pobierania ścieżki
func get_enemy_path():
	return path
