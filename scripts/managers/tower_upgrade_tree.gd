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
		"name": "Podstawowa wieża",
		"upgrades": [
			{"id": 0, "name": "Zwiększone obrażenia I", "type": UpgradeType.DAMAGE, "cost": 5, "value": 0.10, "unlocked": false, "requires": []},
			{"id": 1, "name": "Zwiększone obrażenia II", "type": UpgradeType.DAMAGE, "cost": 10, "value": 0.15, "unlocked": false, "requires": [0]},
			{"id": 2, "name": "Zwiększone obrażenia III", "type": UpgradeType.DAMAGE, "cost": 20, "value": 0.25, "unlocked": false, "requires": [1]},
			{"id": 3, "name": "Szybszy atak I", "type": UpgradeType.FIRE_RATE, "cost": 5, "value": 0.10, "unlocked": false, "requires": []},
			{"id": 4, "name": "Szybszy atak II", "type": UpgradeType.FIRE_RATE, "cost": 10, "value": 0.15, "unlocked": false, "requires": [3]},
			{"id": 5, "name": "Szybszy atak III", "type": UpgradeType.FIRE_RATE, "cost": 20, "value": 0.25, "unlocked": false, "requires": [4]},
			{"id": 6, "name": "Większy zasięg I", "type": UpgradeType.RANGE, "cost": 8, "value": 0.15, "unlocked": false, "requires": []},
			{"id": 7, "name": "Większy zasięg II", "type": UpgradeType.RANGE, "cost": 15, "value": 0.20, "unlocked": false, "requires": [6]},
			{"id": 8, "name": "Podwójny strzał", "type": UpgradeType.SPECIAL, "cost": 30, "value": 2.0, "unlocked": false, "requires": [2, 5]},
		]
	},
	"ice": {
		"name": "Lodowa wieża",
		"upgrades": [
			{"id": 0, "name": "Mocniejsze spowolnienie I", "type": UpgradeType.DAMAGE, "cost": 5, "value": 0.10, "unlocked": false, "requires": []},
			{"id": 1, "name": "Mocniejsze spowolnienie II", "type": UpgradeType.DAMAGE, "cost": 10, "value": 0.15, "unlocked": false, "requires": [0]},
			{"id": 2, "name": "Mocniejsze spowolnienie III", "type": UpgradeType.DAMAGE, "cost": 20, "value": 0.25, "unlocked": false, "requires": [1]},
			{"id": 3, "name": "Częstsze ataki I", "type": UpgradeType.FIRE_RATE, "cost": 5, "value": 0.10, "unlocked": false, "requires": []},
			{"id": 4, "name": "Częstsze ataki II", "type": UpgradeType.FIRE_RATE, "cost": 10, "value": 0.15, "unlocked": false, "requires": [3]},
			{"id": 5, "name": "Częstsze ataki III", "type": UpgradeType.FIRE_RATE, "cost": 20, "value": 0.25, "unlocked": false, "requires": [4]},
			{"id": 6, "name": "Większy zasięg I", "type": UpgradeType.RANGE, "cost": 8, "value": 0.15, "unlocked": false, "requires": []},
			{"id": 7, "name": "Większy zasięg II", "type": UpgradeType.RANGE, "cost": 15, "value": 0.20, "unlocked": false, "requires": [6]},
			{"id": 8, "name": "Zamrażanie", "type": UpgradeType.SPECIAL, "cost": 30, "value": 1.0, "unlocked": false, "requires": [2, 5]},
		]
	},
	"rocket": {
		"name": "Rakietowa wieża",
		"upgrades": [
			{"id": 0, "name": "Większy wybuch I", "type": UpgradeType.DAMAGE, "cost": 5, "value": 0.15, "unlocked": false, "requires": []},
			{"id": 1, "name": "Większy wybuch II", "type": UpgradeType.DAMAGE, "cost": 10, "value": 0.20, "unlocked": false, "requires": [0]},
			{"id": 2, "name": "Większy wybuch III", "type": UpgradeType.DAMAGE, "cost": 20, "value": 0.30, "unlocked": false, "requires": [1]},
			{"id": 3, "name": "Szybsze przeładowanie I", "type": UpgradeType.FIRE_RATE, "cost": 5, "value": 0.10, "unlocked": false, "requires": []},
			{"id": 4, "name": "Szybsze przeładowanie II", "type": UpgradeType.FIRE_RATE, "cost": 10, "value": 0.15, "unlocked": false, "requires": [3]},
			{"id": 5, "name": "Szybsze przeładowanie III", "type": UpgradeType.FIRE_RATE, "cost": 20, "value": 0.25, "unlocked": false, "requires": [4]},
			{"id": 6, "name": "Większy zasięg I", "type": UpgradeType.RANGE, "cost": 8, "value": 0.15, "unlocked": false, "requires": []},
			{"id": 7, "name": "Większy zasięg II", "type": UpgradeType.RANGE, "cost": 15, "value": 0.20, "unlocked": false, "requires": [6]},
			{"id": 8, "name": "Rakiety naprowadzane", "type": UpgradeType.SPECIAL, "cost": 35, "value": 1.5, "unlocked": false, "requires": [2, 5]},
		]
	},
	"sniper": {
		"name": "Snajperska wieża",
		"upgrades": [
			{"id": 0, "name": "Zwiększone obrażenia I", "type": UpgradeType.DAMAGE, "cost": 5, "value": 0.20, "unlocked": false, "requires": []},
			{"id": 1, "name": "Zwiększone obrażenia II", "type": UpgradeType.DAMAGE, "cost": 10, "value": 0.25, "unlocked": false, "requires": [0]},
			{"id": 2, "name": "Zwiększone obrażenia III", "type": UpgradeType.DAMAGE, "cost": 20, "value": 0.35, "unlocked": false, "requires": [1]},
			{"id": 3, "name": "Szybszy strzał I", "type": UpgradeType.FIRE_RATE, "cost": 5, "value": 0.10, "unlocked": false, "requires": []},
			{"id": 4, "name": "Szybszy strzał II", "type": UpgradeType.FIRE_RATE, "cost": 10, "value": 0.15, "unlocked": false, "requires": [3]},
			{"id": 5, "name": "Szybszy strzał III", "type": UpgradeType.FIRE_RATE, "cost": 20, "value": 0.25, "unlocked": false, "requires": [4]},
			{"id": 6, "name": "Większy zasięg I", "type": UpgradeType.RANGE, "cost": 8, "value": 0.20, "unlocked": false, "requires": []},
			{"id": 7, "name": "Większy zasięg II", "type": UpgradeType.RANGE, "cost": 15, "value": 0.30, "unlocked": false, "requires": [6]},
			{"id": 8, "name": "Przebijające pociski", "type": UpgradeType.SPECIAL, "cost": 35, "value": 3.0, "unlocked": false, "requires": [2, 5]},
		]
	},
	"machine_gun": {
		"name": "Karabinowa wieża",
		"upgrades": [
			{"id": 0, "name": "Zwiększone obrażenia I", "type": UpgradeType.DAMAGE, "cost": 5, "value": 0.10, "unlocked": false, "requires": []},
			{"id": 1, "name": "Zwiększone obrażenia II", "type": UpgradeType.DAMAGE, "cost": 10, "value": 0.15, "unlocked": false, "requires": [0]},
			{"id": 2, "name": "Zwiększone obrażenia III", "type": UpgradeType.DAMAGE, "cost": 20, "value": 0.25, "unlocked": false, "requires": [1]},
			{"id": 3, "name": "Większa szybkostrzelność I", "type": UpgradeType.FIRE_RATE, "cost": 5, "value": 0.15, "unlocked": false, "requires": []},
			{"id": 4, "name": "Większa szybkostrzelność II", "type": UpgradeType.FIRE_RATE, "cost": 10, "value": 0.20, "unlocked": false, "requires": [3]},
			{"id": 5, "name": "Większa szybkostrzelność III", "type": UpgradeType.FIRE_RATE, "cost": 20, "value": 0.30, "unlocked": false, "requires": [4]},
			{"id": 6, "name": "Większy zasięg I", "type": UpgradeType.RANGE, "cost": 8, "value": 0.15, "unlocked": false, "requires": []},
			{"id": 7, "name": "Większy zasięg II", "type": UpgradeType.RANGE, "cost": 15, "value": 0.20, "unlocked": false, "requires": [6]},
			{"id": 8, "name": "Pocisk wybuchowy", "type": UpgradeType.SPECIAL, "cost": 30, "value": 1.0, "unlocked": false, "requires": [2, 5]},
		]
	},
	"area": {
		"name": "Obszarowa wieża",
		"upgrades": [
			{"id": 0, "name": "Zwiększone obrażenia I", "type": UpgradeType.DAMAGE, "cost": 5, "value": 0.10, "unlocked": false, "requires": []},
			{"id": 1, "name": "Zwiększone obrażenia II", "type": UpgradeType.DAMAGE, "cost": 10, "value": 0.15, "unlocked": false, "requires": [0]},
			{"id": 2, "name": "Zwiększone obrażenia III", "type": UpgradeType.DAMAGE, "cost": 20, "value": 0.25, "unlocked": false, "requires": [1]},
			{"id": 3, "name": "Szybszy atak I", "type": UpgradeType.FIRE_RATE, "cost": 5, "value": 0.10, "unlocked": false, "requires": []},
			{"id": 4, "name": "Szybszy atak II", "type": UpgradeType.FIRE_RATE, "cost": 10, "value": 0.15, "unlocked": false, "requires": [3]},
			{"id": 5, "name": "Szybszy atak III", "type": UpgradeType.FIRE_RATE, "cost": 20, "value": 0.25, "unlocked": false, "requires": [4]},
			{"id": 6, "name": "Większy zasięg I", "type": UpgradeType.RANGE, "cost": 8, "value": 0.15, "unlocked": false, "requires": []},
			{"id": 7, "name": "Większy zasięg II", "type": UpgradeType.RANGE, "cost": 15, "value": 0.20, "unlocked": false, "requires": [6]},
			{"id": 8, "name": "Podwójny wybuch", "type": UpgradeType.SPECIAL, "cost": 30, "value": 1.5, "unlocked": false, "requires": [2, 5]},
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
