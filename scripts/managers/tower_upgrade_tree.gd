extends Node

const SAVE_PATH = "user://tower_upgrades.save"

enum UpgradeType {
	DAMAGE,
	FIRE_RATE,
	RANGE,
	SPECIAL
}

var tower_upgrades = {
	"basic": {
		"name": "Basic Tower",
		"upgrades": [
			{"id": 0, "name": "Increased Damage I", "type": UpgradeType.DAMAGE, "cost": 5, "value": 0.10, "unlocked": false, "requires": []},
			{"id": 1, "name": "Increased Damage II", "type": UpgradeType.DAMAGE, "cost": 10, "value": 0.15, "unlocked": false, "requires": [0]},
			{"id": 2, "name": "Increased Damage III", "type": UpgradeType.DAMAGE, "cost": 20, "value": 0.25, "unlocked": false, "requires": [1]},
			{"id": 3, "name": "Faster Attack I", "type": UpgradeType.FIRE_RATE, "cost": 5, "value": 0.10, "unlocked": false, "requires": []},
			{"id": 4, "name": "Faster Attack II", "type": UpgradeType.FIRE_RATE, "cost": 10, "value": 0.15, "unlocked": false, "requires": [3]},
			{"id": 5, "name": "Faster Attack III", "type": UpgradeType.FIRE_RATE, "cost": 20, "value": 0.25, "unlocked": false, "requires": [4]},
			{"id": 6, "name": "Extended Range I", "type": UpgradeType.RANGE, "cost": 8, "value": 0.15, "unlocked": false, "requires": []},
			{"id": 7, "name": "Extended Range II", "type": UpgradeType.RANGE, "cost": 15, "value": 0.20, "unlocked": false, "requires": [6]},
			{"id": 8, "name": "Double Shot", "type": UpgradeType.SPECIAL, "cost": 30, "value": 2.0, "unlocked": false, "requires": [2, 5]},
		]
	},
	"ice": {
		"name": "Ice Tower",
		"upgrades": [
			{"id": 0, "name": "Stronger Slow I", "type": UpgradeType.DAMAGE, "cost": 5, "value": 0.10, "unlocked": false, "requires": []},
			{"id": 1, "name": "Stronger Slow II", "type": UpgradeType.DAMAGE, "cost": 10, "value": 0.15, "unlocked": false, "requires": [0]},
			{"id": 2, "name": "Stronger Slow III", "type": UpgradeType.DAMAGE, "cost": 20, "value": 0.25, "unlocked": false, "requires": [1]},
			{"id": 3, "name": "Faster Attack I", "type": UpgradeType.FIRE_RATE, "cost": 5, "value": 0.10, "unlocked": false, "requires": []},
			{"id": 4, "name": "Faster Attack II", "type": UpgradeType.FIRE_RATE, "cost": 10, "value": 0.15, "unlocked": false, "requires": [3]},
			{"id": 5, "name": "Faster Attack III", "type": UpgradeType.FIRE_RATE, "cost": 20, "value": 0.25, "unlocked": false, "requires": [4]},
			{"id": 6, "name": "Extended Range I", "type": UpgradeType.RANGE, "cost": 8, "value": 0.15, "unlocked": false, "requires": []},
			{"id": 7, "name": "Extended Range II", "type": UpgradeType.RANGE, "cost": 15, "value": 0.20, "unlocked": false, "requires": [6]},
			{"id": 8, "name": "Deep Freeze", "type": UpgradeType.SPECIAL, "cost": 30, "value": 1.0, "unlocked": false, "requires": [2, 5]},
		]
	},
	"rocket": {
		"name": "Rocket Tower",
		"upgrades": [
			{"id": 0, "name": "Bigger Explosion I", "type": UpgradeType.DAMAGE, "cost": 5, "value": 0.15, "unlocked": false, "requires": []},
			{"id": 1, "name": "Bigger Explosion II", "type": UpgradeType.DAMAGE, "cost": 10, "value": 0.20, "unlocked": false, "requires": [0]},
			{"id": 2, "name": "Bigger Explosion III", "type": UpgradeType.DAMAGE, "cost": 20, "value": 0.30, "unlocked": false, "requires": [1]},
			{"id": 3, "name": "Faster Reload I", "type": UpgradeType.FIRE_RATE, "cost": 5, "value": 0.10, "unlocked": false, "requires": []},
			{"id": 4, "name": "Faster Reload II", "type": UpgradeType.FIRE_RATE, "cost": 10, "value": 0.15, "unlocked": false, "requires": [3]},
			{"id": 5, "name": "Faster Reload III", "type": UpgradeType.FIRE_RATE, "cost": 20, "value": 0.25, "unlocked": false, "requires": [4]},
			{"id": 6, "name": "Extended Range I", "type": UpgradeType.RANGE, "cost": 8, "value": 0.15, "unlocked": false, "requires": []},
			{"id": 7, "name": "Extended Range II", "type": UpgradeType.RANGE, "cost": 15, "value": 0.20, "unlocked": false, "requires": [6]},
			{"id": 8, "name": "Guided Missiles", "type": UpgradeType.SPECIAL, "cost": 35, "value": 1.5, "unlocked": false, "requires": [2, 5]},
		]
	},
	"sniper": {
		"name": "Sniper Tower",
		"upgrades": [
			{"id": 0, "name": "Increased Damage I", "type": UpgradeType.DAMAGE, "cost": 5, "value": 0.20, "unlocked": false, "requires": []},
			{"id": 1, "name": "Increased Damage II", "type": UpgradeType.DAMAGE, "cost": 10, "value": 0.25, "unlocked": false, "requires": [0]},
			{"id": 2, "name": "Increased Damage III", "type": UpgradeType.DAMAGE, "cost": 20, "value": 0.35, "unlocked": false, "requires": [1]},
			{"id": 3, "name": "Faster Shot I", "type": UpgradeType.FIRE_RATE, "cost": 5, "value": 0.10, "unlocked": false, "requires": []},
			{"id": 4, "name": "Faster Shot II", "type": UpgradeType.FIRE_RATE, "cost": 10, "value": 0.15, "unlocked": false, "requires": [3]},
			{"id": 5, "name": "Faster Shot III", "type": UpgradeType.FIRE_RATE, "cost": 20, "value": 0.25, "unlocked": false, "requires": [4]},
			{"id": 6, "name": "Extended Range I", "type": UpgradeType.RANGE, "cost": 8, "value": 0.20, "unlocked": false, "requires": []},
			{"id": 7, "name": "Extended Range II", "type": UpgradeType.RANGE, "cost": 15, "value": 0.30, "unlocked": false, "requires": [6]},
			{"id": 8, "name": "Piercing Bullets", "type": UpgradeType.SPECIAL, "cost": 35, "value": 3.0, "unlocked": false, "requires": [2, 5]},
		]
	},
	"machine_gun": {
		"name": "Machine Gun Tower",
		"upgrades": [
			{"id": 0, "name": "Increased Damage I", "type": UpgradeType.DAMAGE, "cost": 5, "value": 0.10, "unlocked": false, "requires": []},
			{"id": 1, "name": "Increased Damage II", "type": UpgradeType.DAMAGE, "cost": 10, "value": 0.15, "unlocked": false, "requires": [0]},
			{"id": 2, "name": "Increased Damage III", "type": UpgradeType.DAMAGE, "cost": 20, "value": 0.25, "unlocked": false, "requires": [1]},
			{"id": 3, "name": "Faster Fire Rate I", "type": UpgradeType.FIRE_RATE, "cost": 5, "value": 0.15, "unlocked": false, "requires": []},
			{"id": 4, "name": "Faster Fire Rate II", "type": UpgradeType.FIRE_RATE, "cost": 10, "value": 0.20, "unlocked": false, "requires": [3]},
			{"id": 5, "name": "Faster Fire Rate III", "type": UpgradeType.FIRE_RATE, "cost": 20, "value": 0.30, "unlocked": false, "requires": [4]},
			{"id": 6, "name": "Extended Range I", "type": UpgradeType.RANGE, "cost": 8, "value": 0.15, "unlocked": false, "requires": []},
			{"id": 7, "name": "Extended Range II", "type": UpgradeType.RANGE, "cost": 15, "value": 0.20, "unlocked": false, "requires": [6]},
			{"id": 8, "name": "Explosive Rounds", "type": UpgradeType.SPECIAL, "cost": 30, "value": 1.0, "unlocked": false, "requires": [2, 5]},
		]
	},
	"magic": {
		"name": "Magic Tower",
		"upgrades": [
			{"id": 0, "name": "Arcane Power I", "type": UpgradeType.DAMAGE, "cost": 10, "value": 0.20, "unlocked": false, "requires": []},
			{"id": 1, "name": "Arcane Power II", "type": UpgradeType.DAMAGE, "cost": 15, "value": 0.30, "unlocked": false, "requires": [0]},
			{"id": 2, "name": "Arcane Power III", "type": UpgradeType.DAMAGE, "cost": 25, "value": 0.40, "unlocked": false, "requires": [1]},
			{"id": 3, "name": "Faster Casting I", "type": UpgradeType.FIRE_RATE, "cost": 10, "value": 0.12, "unlocked": false, "requires": []},
			{"id": 4, "name": "Faster Casting II", "type": UpgradeType.FIRE_RATE, "cost": 15, "value": 0.18, "unlocked": false, "requires": [3]},
			{"id": 5, "name": "Faster Casting III", "type": UpgradeType.FIRE_RATE, "cost": 25, "value": 0.25, "unlocked": false, "requires": [4]},
			{"id": 6, "name": "Extended Range I", "type": UpgradeType.RANGE, "cost": 12, "value": 0.20, "unlocked": false, "requires": []},
			{"id": 7, "name": "Extended Range II", "type": UpgradeType.RANGE, "cost": 18, "value": 0.25, "unlocked": false, "requires": [6]},
			{"id": 8, "name": "Chain Lightning", "type": UpgradeType.SPECIAL, "cost": 40, "value": 3.0, "unlocked": false, "requires": [2, 5]},
		]
	},
	"area": {
		"name": "Area Tower",
		"upgrades": [
			{"id": 0, "name": "Increased Damage I", "type": UpgradeType.DAMAGE, "cost": 5, "value": 0.10, "unlocked": false, "requires": []},
			{"id": 1, "name": "Increased Damage II", "type": UpgradeType.DAMAGE, "cost": 10, "value": 0.15, "unlocked": false, "requires": [0]},
			{"id": 2, "name": "Increased Damage III", "type": UpgradeType.DAMAGE, "cost": 20, "value": 0.25, "unlocked": false, "requires": [1]},
			{"id": 3, "name": "Faster Attack I", "type": UpgradeType.FIRE_RATE, "cost": 5, "value": 0.10, "unlocked": false, "requires": []},
			{"id": 4, "name": "Faster Attack II", "type": UpgradeType.FIRE_RATE, "cost": 10, "value": 0.15, "unlocked": false, "requires": [3]},
			{"id": 5, "name": "Faster Attack III", "type": UpgradeType.FIRE_RATE, "cost": 20, "value": 0.25, "unlocked": false, "requires": [4]},
			{"id": 6, "name": "Extended Range I", "type": UpgradeType.RANGE, "cost": 8, "value": 0.15, "unlocked": false, "requires": []},
			{"id": 7, "name": "Extended Range II", "type": UpgradeType.RANGE, "cost": 15, "value": 0.20, "unlocked": false, "requires": [6]},
			{"id": 8, "name": "Double Burst", "type": UpgradeType.SPECIAL, "cost": 30, "value": 1.5, "unlocked": false, "requires": [2, 5]},
		]
	}
}

func _ready():
	load_upgrades()

func get_tower_upgrades(tower_type: String) -> Array:
	if tower_upgrades.has(tower_type):
		return tower_upgrades[tower_type]["upgrades"]
	return []

func is_upgrade_unlocked(tower_type: String, upgrade_id: int) -> bool:
	if tower_upgrades.has(tower_type):
		var upgrades = tower_upgrades[tower_type]["upgrades"]
		for upgrade in upgrades:
			if upgrade["id"] == upgrade_id:
				return upgrade["unlocked"]
	return false

func can_unlock_upgrade(tower_type: String, upgrade_id: int) -> bool:
	if not tower_upgrades.has(tower_type):
		return false
	
	var upgrades = tower_upgrades[tower_type]["upgrades"]
	var target_upgrade = null
	
	for upgrade in upgrades:
		if upgrade["id"] == upgrade_id:
			target_upgrade = upgrade
			break
	
	if not target_upgrade or target_upgrade["unlocked"]:
		return false
	
	for req_id in target_upgrade["requires"]:
		if not is_upgrade_unlocked(tower_type, req_id):
			return false
	
	return true

func unlock_upgrade(tower_type: String, upgrade_id: int) -> bool:
	if not can_unlock_upgrade(tower_type, upgrade_id):
		return false
	
	var upgrades = tower_upgrades[tower_type]["upgrades"]
	for upgrade in upgrades:
		if upgrade["id"] == upgrade_id:
			upgrade["unlocked"] = true
			save_upgrades()
			return true
	
	return false

func get_upgrade_cost(tower_type: String, upgrade_id: int) -> int:
	if tower_upgrades.has(tower_type):
		var upgrades = tower_upgrades[tower_type]["upgrades"]
		for upgrade in upgrades:
			if upgrade["id"] == upgrade_id:
				return upgrade["cost"]
	return 0

func get_tower_bonus(tower_type: String, upgrade_type: UpgradeType) -> float:
	var bonus = 0.0
	if tower_upgrades.has(tower_type):
		var upgrades = tower_upgrades[tower_type]["upgrades"]
		for upgrade in upgrades:
			if upgrade["unlocked"] and upgrade["type"] == upgrade_type:
				bonus += upgrade["value"]
	return bonus

func has_special_upgrade(tower_type: String) -> bool:
	if tower_upgrades.has(tower_type):
		var upgrades = tower_upgrades[tower_type]["upgrades"]
		for upgrade in upgrades:
			if upgrade["unlocked"] and upgrade["type"] == UpgradeType.SPECIAL:
				return true
	return false

func get_special_upgrade_value(tower_type: String) -> float:
	if tower_upgrades.has(tower_type):
		var upgrades = tower_upgrades[tower_type]["upgrades"]
		for upgrade in upgrades:
			if upgrade["unlocked"] and upgrade["type"] == UpgradeType.SPECIAL:
				return upgrade["value"]
	return 0.0

func save_upgrades():
	var save_data = {}
	for tower_type in tower_upgrades.keys():
		save_data[tower_type] = []
		for upgrade in tower_upgrades[tower_type]["upgrades"]:
			if upgrade["unlocked"]:
				save_data[tower_type].append(upgrade["id"])
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_var(save_data)
		file.close()

func load_upgrades():
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		if file:
			var save_data = file.get_var()
			file.close()
			
			for tower_type in save_data.keys():
				if tower_upgrades.has(tower_type):
					for upgrade_id in save_data[tower_type]:
						for upgrade in tower_upgrades[tower_type]["upgrades"]:
							if upgrade["id"] == upgrade_id:
								upgrade["unlocked"] = true

func reset_all_upgrades():
	for tower_type in tower_upgrades.keys():
		for upgrade in tower_upgrades[tower_type]["upgrades"]:
			upgrade["unlocked"] = false
	save_upgrades()
