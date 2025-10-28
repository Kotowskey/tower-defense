extends Node

enum GameMode {CLASSIC, TOWER_RUSH}

var current_mode = GameMode.CLASSIC

func set_game_mode(mode: GameMode):
	current_mode = mode
	print("Game mode set to: ", "CLASSIC" if mode == GameMode.CLASSIC else "TOWER_RUSH")

func get_game_mode() -> GameMode:
	return current_mode

func is_tower_rush() -> bool:
	return current_mode == GameMode.TOWER_RUSH

func is_classic() -> bool:
	return current_mode == GameMode.CLASSIC

func get_game_scene_path() -> String:
	if current_mode == GameMode.TOWER_RUSH:
		return "res://scenes/tower_rush_scene.tscn"
	else:
		return "res://scenes/game_scene.tscn"
