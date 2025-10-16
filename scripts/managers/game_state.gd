extends Node

signal money_changed(amount)
signal lives_changed(amount)
signal wave_changed(wave_number)
signal game_over

var player_money: int = 500
var player_lives: int = 10
var current_wave: int = 0
var difficulty_multiplier: float = 1.0

var enemy_reward: int = 25
var tower_cost: int = 100

var enemy_rewards = {}
var talent_manager

func _ready():
	if has_node("/root/TalentManager"):
		talent_manager = get_node("/root/TalentManager")

func set_initial_values(money: int, lives: int, reward: int):
	if has_node("/root/TalentManager"):
		talent_manager = get_node("/root/TalentManager")
	
	var bonus_money = 0
	var bonus_lives = 0
	
	if talent_manager:
		bonus_money = int(talent_manager.get_talent_bonus("starting_money"))
		bonus_lives = int(talent_manager.get_talent_bonus("starting_lives"))
	
	player_money = money + bonus_money
	player_lives = lives + bonus_lives
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
	var base_reward = enemy_reward
	if enemy_rewards.has(enemy_type):
		base_reward = enemy_rewards[enemy_type]
	
	if talent_manager:
		var income_bonus = talent_manager.get_talent_bonus("income_multiplier")
		base_reward = int(base_reward * (1.0 + income_bonus))
	
	return base_reward

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
	var wave_reward = 100 + (current_wave * 20)
	
	if is_boss_wave:
		wave_reward *= 2
	
	if talent_manager:
		var wave_bonus = talent_manager.get_talent_bonus("wave_reward")
		wave_reward = int(wave_reward * (1.0 + wave_bonus))
	
	return wave_reward
