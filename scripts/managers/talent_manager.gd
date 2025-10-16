extends Node

signal talent_unlocked(talent_id)
signal talent_points_changed(points)

var talent_points: int = 0
var unlocked_talents: Dictionary = {}

var talents: Dictionary = {
	"damage_boost_1": {
		"name": "Damage Boost I",
		"description": "Zwiększa obrażenia wież o 10%",
		"cost": 1,
		"requires": [],
		"effect_type": "tower_damage",
		"effect_value": 0.10,
		"tier": 1
	},
	"damage_boost_2": {
		"name": "Damage Boost II",
		"description": "Zwiększa obrażenia wież o 20%",
		"cost": 2,
		"requires": ["damage_boost_1"],
		"effect_type": "tower_damage",
		"effect_value": 0.20,
		"tier": 2
	},
	"damage_boost_3": {
		"name": "Damage Boost III",
		"description": "Zwiększa obrażenia wież o 35%",
		"cost": 3,
		"requires": ["damage_boost_2"],
		"effect_type": "tower_damage",
		"effect_value": 0.35,
		"tier": 3
	},
	"range_boost_1": {
		"name": "Range Boost I",
		"description": "Zwiększa zasięg wież o 15%",
		"cost": 1,
		"requires": [],
		"effect_type": "tower_range",
		"effect_value": 0.15,
		"tier": 1
	},
	"range_boost_2": {
		"name": "Range Boost II",
		"description": "Zwiększa zasięg wież o 30%",
		"cost": 2,
		"requires": ["range_boost_1"],
		"effect_type": "tower_range",
		"effect_value": 0.30,
		"tier": 2
	},
	"range_boost_3": {
		"name": "Range Boost III",
		"description": "Zwiększa zasięg wież o 50%",
		"cost": 3,
		"requires": ["range_boost_2"],
		"effect_type": "tower_range",
		"effect_value": 0.50,
		"tier": 3
	},
	"attack_speed_1": {
		"name": "Attack Speed I",
		"description": "Zwiększa szybkość ataku o 15%",
		"cost": 1,
		"requires": [],
		"effect_type": "attack_speed",
		"effect_value": 0.15,
		"tier": 1
	},
	"attack_speed_2": {
		"name": "Attack Speed II",
		"description": "Zwiększa szybkość ataku o 30%",
		"cost": 2,
		"requires": ["attack_speed_1"],
		"effect_type": "attack_speed",
		"effect_value": 0.30,
		"tier": 2
	},
	"attack_speed_3": {
		"name": "Attack Speed III",
		"description": "Zwiększa szybkość ataku o 50%",
		"cost": 3,
		"requires": ["attack_speed_2"],
		"effect_type": "attack_speed",
		"effect_value": 0.50,
		"tier": 3
	},
	"starting_money_1": {
		"name": "Starting Capital I",
		"description": "Dodatkowe 200 złota na start",
		"cost": 2,
		"requires": [],
		"effect_type": "starting_money",
		"effect_value": 200,
		"tier": 1
	},
	"starting_money_2": {
		"name": "Starting Capital II",
		"description": "Dodatkowe 500 złota na start",
		"cost": 3,
		"requires": ["starting_money_1"],
		"effect_type": "starting_money",
		"effect_value": 500,
		"tier": 2
	},
	"income_boost_1": {
		"name": "Income Boost I",
		"description": "Zwiększa nagrody o 20%",
		"cost": 2,
		"requires": [],
		"effect_type": "income_multiplier",
		"effect_value": 0.20,
		"tier": 1
	},
	"income_boost_2": {
		"name": "Income Boost II",
		"description": "Zwiększa nagrody o 40%",
		"cost": 3,
		"requires": ["income_boost_1"],
		"effect_type": "income_multiplier",
		"effect_value": 0.40,
		"tier": 2
	},
	"tower_discount_1": {
		"name": "Tower Discount I",
		"description": "Wieże kosztują 10% mniej",
		"cost": 2,
		"requires": [],
		"effect_type": "tower_cost",
		"effect_value": -0.10,
		"tier": 1
	},
	"tower_discount_2": {
		"name": "Tower Discount II",
		"description": "Wieże kosztują 20% mniej",
		"cost": 3,
		"requires": ["tower_discount_1"],
		"effect_type": "tower_cost",
		"effect_value": -0.20,
		"tier": 2
	},
	"extra_lives_1": {
		"name": "Extra Lives I",
		"description": "Dodatkowe 5 żyć na start",
		"cost": 2,
		"requires": [],
		"effect_type": "starting_lives",
		"effect_value": 5,
		"tier": 1
	},
	"extra_lives_2": {
		"name": "Extra Lives II",
		"description": "Dodatkowe 10 żyć na start",
		"cost": 3,
		"requires": ["extra_lives_1"],
		"effect_type": "starting_lives",
		"effect_value": 10,
		"tier": 2
	},
	"critical_hit": {
		"name": "Critical Strike",
		"description": "10% szans na podwójne obrażenia",
		"cost": 4,
		"requires": ["damage_boost_2"],
		"effect_type": "critical_chance",
		"effect_value": 0.10,
		"tier": 3
	},
	"splash_damage": {
		"name": "Splash Damage",
		"description": "Wieże zadają 30% obrażeń w małym promieniu",
		"cost": 4,
		"requires": ["damage_boost_2", "range_boost_2"],
		"effect_type": "splash_damage",
		"effect_value": 0.30,
		"tier": 3
	},
	"wave_bonus": {
		"name": "Wave Master",
		"description": "Zwiększa nagrody za ukończenie fali o 50%",
		"cost": 3,
		"requires": ["income_boost_1"],
		"effect_type": "wave_reward",
		"effect_value": 0.50,
		"tier": 2
	}
}

func _ready():
	load_talents()

func add_talent_points(points: int):
	talent_points += points
	emit_signal("talent_points_changed", talent_points)
	save_talents()

func can_unlock_talent(talent_id: String) -> bool:
	if not talents.has(talent_id):
		return false
	
	if unlocked_talents.has(talent_id):
		return false
	
	var talent = talents[talent_id]
	
	if talent_points < talent["cost"]:
		return false
	
	for required_id in talent["requires"]:
		if not unlocked_talents.has(required_id):
			return false
	
	return true

func unlock_talent(talent_id: String) -> bool:
	if not can_unlock_talent(talent_id):
		return false
	
	var talent = talents[talent_id]
	talent_points -= talent["cost"]
	unlocked_talents[talent_id] = true
	
	emit_signal("talent_unlocked", talent_id)
	emit_signal("talent_points_changed", talent_points)
	save_talents()
	return true

func is_talent_unlocked(talent_id: String) -> bool:
	return unlocked_talents.has(talent_id)

func get_talent_bonus(effect_type: String) -> float:
	var total_bonus = 0.0
	
	for talent_id in unlocked_talents:
		if talents.has(talent_id):
			var talent = talents[talent_id]
			if talent["effect_type"] == effect_type:
				total_bonus += talent["effect_value"]
	
	return total_bonus

func has_talent_effect(effect_type: String) -> bool:
	for talent_id in unlocked_talents:
		if talents.has(talent_id):
			if talents[talent_id]["effect_type"] == effect_type:
				return true
	return false

func reset_talents():
	var refund = 0
	for talent_id in unlocked_talents:
		if talents.has(talent_id):
			refund += talents[talent_id]["cost"]
	
	unlocked_talents.clear()
	talent_points += refund
	emit_signal("talent_points_changed", talent_points)
	save_talents()

func save_talents():
	var save_data = {
		"talent_points": talent_points,
		"unlocked_talents": unlocked_talents.keys()
	}
	
	var save_file = FileAccess.open("user://talents.save", FileAccess.WRITE)
	if save_file:
		save_file.store_var(save_data)
		save_file.close()

func load_talents():
	if not FileAccess.file_exists("user://talents.save"):
		return
	
	var save_file = FileAccess.open("user://talents.save", FileAccess.READ)
	if save_file:
		var save_data = save_file.get_var()
		save_file.close()
		
		if save_data:
			talent_points = save_data.get("talent_points", 0)
			unlocked_talents.clear()
			for talent_id in save_data.get("unlocked_talents", []):
				unlocked_talents[talent_id] = true
			
			emit_signal("talent_points_changed", talent_points)
