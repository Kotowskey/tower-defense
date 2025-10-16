extends Node

signal money_changed(amount)
signal lives_changed(amount)
signal wave_changed(wave_number)
signal game_over

var player_money: int = 250
var player_lives: int = 10
var current_wave: int = 0
var difficulty_multiplier: float = 1.0

var enemy_reward: int = 15
var tower_cost: int = 100

var enemy_rewards = {}

func _ready():
	pass

func set_initial_values(money: int, lives: int, reward: int):
	player_money = money
	player_lives = lives
	enemy_reward = reward
	emit_signal("money_changed", player_money)
	emit_signal("lives_changed", player_lives)
	emit_signal("wave_changed", current_wave)

func setup_enemy_rewards():
	enemy_rewards = {
		0: enemy_reward,
		1: int(enemy_reward * 1.4),
		2: int(enemy_reward * 1.8),
		3: int(enemy_reward * 1.6),
		4: int(enemy_reward * 2.0)
	}

func get_enemy_reward(enemy_type = 0):
	if enemy_rewards.has(enemy_type):
		return enemy_rewards[enemy_type]
	return enemy_reward

func add_money(amount: int):
	player_money += amount
	emit_signal("money_changed", player_money)

func reduce_money(amount: int) -> bool:
	if player_money >= amount:
		player_money -= amount
		emit_signal("money_changed", player_money)
		return true
	return false

func reduce_lives(amount: int = 1):
	player_lives -= amount
	emit_signal("lives_changed", player_lives)
	
	if player_lives <= 0:
		emit_signal("game_over")

func has_enough_money(amount: int) -> bool:
	return player_money >= amount

func next_wave():
	current_wave += 1
	emit_signal("wave_changed", current_wave)
	return current_wave

func get_current_wave() -> int:
	return current_wave

func get_wave_reward() -> int:
	var is_boss_wave = (current_wave % 5 == 0)
	var wave_reward = 50 + (current_wave * 15)
	
	if is_boss_wave:
		wave_reward *= 2
	
	return wave_reward
