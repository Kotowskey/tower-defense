extends Node

enum TowerType {
	BASIC,
	ROCKET,
	SNIPER,
	ICE
}

var tower_properties = {
	TowerType.BASIC: {
		"name": "Basic Tower",
		"cost": 100,
		"range": 300.0,
		"damage": 10,
		"fire_rate": 1.0,
		"sprite": "res://assets/towers/basic-tower-top.svg",
		"description": "Standard tower with balanced stats"
	},
	TowerType.ROCKET: {
		"name": "Rocket Tower",
		"cost": 200,
		"range": 250.0,
		"damage": 5,
		"fire_rate": 1.5,
		"sprite": "res://assets/towers/rocket-tower-top.svg",
		"description": "Deals damage to all enemies in range"
	},
	TowerType.SNIPER: {
		"name": "Sniper Tower",
		"cost": 300,
		"range": 500.0,
		"damage": 30,
		"fire_rate": 2.0,
		"sprite": "res://assets/towers/sniper-tower-top.svg", 
		"description": "Long range and high damage but slow fire rate"
	},
	TowerType.ICE: {
		"name": "Ice Tower",
		"cost": 150,
		"range": 250.0,
		"damage": 5,
		"fire_rate": 1.0,
		"slow_factor": 0.5,
		"slow_duration": 2.0,
		"sprite": "res://assets/towers/ice-tower-top.svg", 
		"description": "Slows down enemies in range"
	}
}

func get_tower_properties(tower_type):
	return tower_properties[tower_type]
