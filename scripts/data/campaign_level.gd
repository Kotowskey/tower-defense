class_name CampaignLevel
extends Resource

@export var level_number: int = 1
@export var level_name: String = ""
@export var max_waves: int = 10
@export var starting_money: int = 300
@export var starting_lives: int = 10
@export var map_path: String = "res://scenes/map.tscn"
@export var difficulty_multiplier: float = 1.0

func _init(
	p_number: int = 1,
	p_name: String = "",
	p_waves: int = 10,
	p_money: int = 300,
	p_lives: int = 10,
	p_map: String = "res://scenes/map.tscn",
	p_difficulty: float = 1.0
):
	level_number = p_number
	level_name = p_name
	max_waves = p_waves
	starting_money = p_money
	starting_lives = p_lives
	map_path = p_map
	difficulty_multiplier = p_difficulty

static func get_campaign_levels() -> Array:
	var levels = []
	
	levels.append(CampaignLevel.new(
		1,
		"First Contact",
		10,
		400,
		15,
		"res://scenes/map.tscn",
		0.8
	))
	
	levels.append(CampaignLevel.new(
		2,
		"Rising Threat",
		15,
		350,
		12,
		"res://scenes/map.tscn",
		1.0
	))
	
	levels.append(CampaignLevel.new(
		3,
		"Enemy Reinforcement",
		20,
		300,
		10,
		"res://scenes/map2.tscn",
		1.2
	))
	
	levels.append(CampaignLevel.new(
		4,
		"Desperate Defense",
		25,
		250,
		8,
		"res://scenes/map2.tscn",
		1.4
	))
	
	levels.append(CampaignLevel.new(
		5,
		"Final Stand",
		30,
		200,
		5,
		"res://scenes/map2.tscn",
		1.6
	))
	
	return levels

static func get_level(level_number: int) -> CampaignLevel:
	var levels = get_campaign_levels()
	for level in levels:
		if level.level_number == level_number:
			return level
	return null
