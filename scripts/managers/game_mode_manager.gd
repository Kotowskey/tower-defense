extends Node

enum GameMode { SANDBOX, CAMPAIGN }

var current_mode: GameMode = GameMode.SANDBOX
var current_campaign_level: int = 1
var max_campaign_levels: int = 5

func set_mode(mode: GameMode):
	current_mode = mode

func get_mode() -> GameMode:
	return current_mode

func is_sandbox() -> bool:
	return current_mode == GameMode.SANDBOX

func is_campaign() -> bool:
	return current_mode == GameMode.CAMPAIGN

func set_campaign_level(level: int):
	current_campaign_level = clamp(level, 1, max_campaign_levels)

func get_campaign_level() -> int:
	return current_campaign_level

func next_campaign_level() -> bool:
	if current_campaign_level < max_campaign_levels:
		current_campaign_level += 1
		return true
	return false

func is_final_level() -> bool:
	return current_campaign_level >= max_campaign_levels

func reset_campaign():
	current_campaign_level = 1
