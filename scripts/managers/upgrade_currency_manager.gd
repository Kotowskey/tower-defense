extends Node

signal currency_changed(new_amount)

var upgrade_points: int = 0
const SAVE_PATH = "user://upgrade_currency.save"

func _ready():
	load_currency()

func add_upgrade_points(amount: int):
	upgrade_points += amount
	save_currency()
	emit_signal("currency_changed", upgrade_points)

func spend_upgrade_points(amount: int) -> bool:
	if upgrade_points >= amount:
		upgrade_points -= amount
		save_currency()
		emit_signal("currency_changed", upgrade_points)
		return true
	return false

func get_upgrade_points() -> int:
	return upgrade_points

func save_currency():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_var(upgrade_points)
		file.close()

func load_currency():
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		if file:
			upgrade_points = file.get_var()
			file.close()
	else:
		upgrade_points = 0

func reset_points():
	upgrade_points = 0
	save_currency()
	emit_signal("currency_changed", upgrade_points)
