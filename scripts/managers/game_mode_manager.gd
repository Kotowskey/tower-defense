extends Node

enum GameMode { SANDBOX, CAMPAIGN }

var current_mode: GameMode = GameMode.SANDBOX
var current_campaign_level: int = 1
var max_campaign_levels: int = 5
var campaign_bonus_money: int = 0
var highest_unlocked_level: int = 1

const SAVE_FILE_PATH = "user://campaign_progress.save"

func _ready():
	load_progress()

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
		if current_campaign_level > highest_unlocked_level:
			highest_unlocked_level = current_campaign_level
		return true
	return false

func is_final_level() -> bool:
	return current_campaign_level >= max_campaign_levels

func reset_campaign():
	current_campaign_level = 1
	campaign_bonus_money = 0

func add_campaign_bonus(money: int):
	campaign_bonus_money += money

func get_campaign_bonus() -> int:
	return campaign_bonus_money

func clear_campaign_bonus():
	campaign_bonus_money = 0

func unlock_level(level: int):
	if level > highest_unlocked_level:
		highest_unlocked_level = level

func is_level_unlocked(level: int) -> bool:
	return level <= highest_unlocked_level

func get_highest_unlocked_level() -> int:
	return highest_unlocked_level

func save_progress():
	var save_data = {
		"highest_unlocked_level": highest_unlocked_level,
		"current_campaign_level": current_campaign_level
	}
	
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	if file:
		file.store_var(save_data)
		file.close()
		print("Campaign progress saved")

func load_progress():
	if FileAccess.file_exists(SAVE_FILE_PATH):
		var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
		if file:
			var save_data = file.get_var()
			file.close()
			
			if save_data.has("highest_unlocked_level"):
				highest_unlocked_level = save_data["highest_unlocked_level"]
			if save_data.has("current_campaign_level"):
				current_campaign_level = save_data["current_campaign_level"]
			
			print("Campaign progress loaded: Level ", current_campaign_level, " / Highest: ", highest_unlocked_level)
	else:
		print("No saved campaign progress found")
