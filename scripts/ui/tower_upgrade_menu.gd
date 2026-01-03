extends Control

signal closed

var upgrade_currency_manager
var tower_upgrade_tree
var current_tower_type = "basic"

var tower_types = ["basic", "ice", "rocket", "sniper", "machine_gun", "magic", "area"]

func _ready():
	if not get_node_or_null("/root/UpgradeCurrencyManager"):
		upgrade_currency_manager = load("res://scripts/managers/upgrade_currency_manager.gd").new()
		upgrade_currency_manager.name = "UpgradeCurrencyManager"
		get_node("/root").add_child(upgrade_currency_manager)
		upgrade_currency_manager._ready()
	else:
		upgrade_currency_manager = get_node("/root/UpgradeCurrencyManager")
	
	if not get_node_or_null("/root/TowerUpgradeTree"):
		tower_upgrade_tree = load("res://scripts/managers/tower_upgrade_tree.gd").new()
		tower_upgrade_tree.name = "TowerUpgradeTree"
		get_node("/root").add_child(tower_upgrade_tree)
		tower_upgrade_tree._ready()
	else:
		tower_upgrade_tree = get_node("/root/TowerUpgradeTree")
	
	setup_ui()
	update_currency_display()
	refresh_upgrades()

func setup_ui():
	if has_node("Panel/VBoxContainer/CloseButton"):
		$Panel/VBoxContainer/CloseButton.connect("pressed", Callable(self, "_on_close_button_pressed"))
		print("Close button connected successfully")
	else:
		print("ERROR: Close button not found!")
	
	for i in range(tower_types.size()):
		var tower_type = tower_types[i]
		var button_path = "Panel/VBoxContainer/TowerSelection/TowerButton" + str(i + 1)
		if has_node(button_path):
			get_node(button_path).connect("pressed", Callable(self, "_on_tower_button_pressed").bind(tower_type))
	
	if has_node("Panel/VBoxContainer/ResetButton"):
		$Panel/VBoxContainer/ResetButton.connect("pressed", Callable(self, "_on_reset_button_pressed"))

func _on_tower_button_pressed(tower_type: String):
	current_tower_type = tower_type
	refresh_upgrades()

func refresh_upgrades():
	var upgrades = tower_upgrade_tree.get_tower_upgrades(current_tower_type)
	var container = $Panel/VBoxContainer/ScrollContainer/UpgradesContainer
	
	for child in container.get_children():
		child.queue_free()
	
	for upgrade in upgrades:
		var upgrade_item = create_upgrade_item(upgrade)
		container.add_child(upgrade_item)

func create_upgrade_item(upgrade: Dictionary) -> Control:
	var item = HBoxContainer.new()
	item.custom_minimum_size = Vector2(0, 60)
	
	var name_label = Label.new()
	name_label.text = upgrade["name"]
	name_label.custom_minimum_size = Vector2(250, 0)
	item.add_child(name_label)
	
	var cost_label = Label.new()
	cost_label.text = "Cost: " + str(upgrade["cost"])
	cost_label.custom_minimum_size = Vector2(100, 0)
	item.add_child(cost_label)
	
	var unlock_button = Button.new()
	if upgrade["unlocked"]:
		unlock_button.text = "UNLOCKED"
		unlock_button.disabled = true
	elif tower_upgrade_tree.can_unlock_upgrade(current_tower_type, upgrade["id"]):
		var current_points = upgrade_currency_manager.get_upgrade_points()
		if current_points >= upgrade["cost"]:
			unlock_button.text = "BUY"
			unlock_button.connect("pressed", Callable(self, "_on_unlock_upgrade").bind(upgrade["id"]))
		else:
			unlock_button.text = "NOT ENOUGH POINTS"
			unlock_button.disabled = true
	else:
		unlock_button.text = "LOCKED"
		unlock_button.disabled = true
	
	unlock_button.custom_minimum_size = Vector2(150, 0)
	item.add_child(unlock_button)
	
	return item

func _on_unlock_upgrade(upgrade_id: int):
	var cost = tower_upgrade_tree.get_upgrade_cost(current_tower_type, upgrade_id)
	
	if not tower_upgrade_tree.can_unlock_upgrade(current_tower_type, upgrade_id):
		print("Cannot unlock upgrade - requirements not met")
		return
	
	if not upgrade_currency_manager.spend_upgrade_points(cost):
		print("Not enough upgrade points")
		return
	
	if tower_upgrade_tree.unlock_upgrade(current_tower_type, upgrade_id):
		update_currency_display()
		refresh_upgrades()
	else:
		upgrade_currency_manager.add_upgrade_points(cost)
		print("Failed to unlock upgrade")

func update_currency_display():
	var points = upgrade_currency_manager.get_upgrade_points()
	$Panel/VBoxContainer/CurrencyLabel.text = "Upgrade Points: " + str(points)

func _on_close_button_pressed():
	print("Close button pressed!")
	emit_signal("closed")
	hide()
	call_deferred("queue_free")

func _on_reset_button_pressed():
	# Calculate total points spent
	var total_spent = 0
	for tower_type in tower_types:
		var upgrades = tower_upgrade_tree.get_tower_upgrades(tower_type)
		for upgrade in upgrades:
			if upgrade["unlocked"]:
				total_spent += upgrade["cost"]
	
	# Reset all upgrades
	tower_upgrade_tree.reset_all_upgrades()
	
	# Refund all points
	upgrade_currency_manager.add_upgrade_points(total_spent)
	
	# Update UI
	update_currency_display()
	refresh_upgrades()
	
	print("Skill points reset! Refunded " + str(total_spent) + " points")
