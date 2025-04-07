extends Node

# Poziomy trudności
enum Difficulty {EASY, NORMAL, HARD}

var current_difficulty = Difficulty.NORMAL

# Mnożniki trudności
var difficulty_multipliers = {
	Difficulty.EASY: {
		"enemy_health": 0.7,
		"enemy_speed": 0.8,
		"player_money": 1.5,
		"enemy_reward": 1.2
	},
	Difficulty.NORMAL: {
		"enemy_health": 1.0,
		"enemy_speed": 1.0,
		"player_money": 1.0,
		"enemy_reward": 1.0
	},
	Difficulty.HARD: {
		"enemy_health": 1.5,
		"enemy_speed": 1.2,
		"player_money": 0.7,
		"enemy_reward": 0.8
	}
}

func get_difficulty_multiplier(property):
	return difficulty_multipliers[current_difficulty][property]

func set_difficulty(difficulty):
	current_difficulty = difficulty
