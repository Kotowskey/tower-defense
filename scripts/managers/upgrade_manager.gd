extends Node

signal upgrade_unlocked(upgrade_id: String)
signal upgrade_purchased(upgrade_id: String)

var unlocked_upgrades: Dictionary = {}
var upgrade_points: int = 0

func _ready():
	_initialize_default_unlocks()

func _initialize_default_unlocks():
	unlocked_upgrades["basic_tower"] = true
	upgrade_points = 1000

func unlock_upgrade(upgrade_id: String) -> bool:
	if unlocked_upgrades.get(upgrade_id, false):
		return false
	
	unlocked_upgrades[upgrade_id] = true
	upgrade_unlocked.emit(upgrade_id)
	return true

func is_upgrade_unlocked(upgrade_id: String) -> bool:
	return unlocked_upgrades.get(upgrade_id, false)

func can_unlock_upgrade(upgrade_id: String, prerequisites: Array[String], cost: int) -> bool:
	if is_upgrade_unlocked(upgrade_id):
		return false
	
	if upgrade_points < cost:
		return false
	
	for prereq in prerequisites:
		if not is_upgrade_unlocked(prereq):
			return false
	
	return true

func purchase_upgrade(upgrade_id: String, cost: int) -> bool:
	if upgrade_points >= cost:
		upgrade_points -= cost
		unlock_upgrade(upgrade_id)
		upgrade_purchased.emit(upgrade_id)
		save_progress()
		return true
	return false

func add_upgrade_points(amount: int):
	upgrade_points += amount

func get_upgrade_points() -> int:
	return upgrade_points

func save_progress():
	var save_data = {
		"unlocked_upgrades": unlocked_upgrades,
		"upgrade_points": upgrade_points
	}
	
	var save_file = FileAccess.open("user://tower_upgrades.save", FileAccess.WRITE)
	if save_file:
		save_file.store_var(save_data)
		save_file.close()

func load_progress():
	if not FileAccess.file_exists("user://tower_upgrades.save"):
		_initialize_default_unlocks()
		return
	
	var save_file = FileAccess.open("user://tower_upgrades.save", FileAccess.READ)
	if save_file:
		var save_data = save_file.get_var()
		save_file.close()
		
		if save_data:
			unlocked_upgrades = save_data.get("unlocked_upgrades", {})
			upgrade_points = save_data.get("upgrade_points", 0)

func reset_progress():
	unlocked_upgrades.clear()
	upgrade_points = 0
	_initialize_default_unlocks()
	save_progress()

func get_tower_upgrades(tower_type: int) -> Dictionary:
	var tower_upgrades = {}
	for upgrade_id in unlocked_upgrades:
		if unlocked_upgrades[upgrade_id]:
			tower_upgrades[upgrade_id] = true
	return tower_upgrades
