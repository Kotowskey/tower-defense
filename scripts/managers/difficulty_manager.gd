extends Node

enum Difficulty {EASY, NORMAL, HARD}

var current_difficulty = Difficulty.NORMAL

var difficulty_multipliers = {
	Difficulty.EASY: {
		"enemy_health": 1.0,
		"enemy_speed": 1.0,
		"player_money": 1.0,
		"enemy_reward": 1.0
	},
	Difficulty.NORMAL: {
		"enemy_health": 1.25,
		"enemy_speed": 1.25,
		"player_money": 0.8,
		"enemy_reward": 0.8
	},
	Difficulty.HARD: {
		"enemy_health": 1.5,
		"enemy_speed": 1.5,
		"player_money": 0.6,
		"enemy_reward": 0.6
	}
}

func get_difficulty_multiplier(property):
	return difficulty_multipliers[current_difficulty][property]

func set_difficulty(difficulty):
	current_difficulty = difficulty
