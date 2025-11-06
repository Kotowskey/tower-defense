extends Control

@onready var upgrade_data = preload("res://scripts/data/tower_upgrade_data.gd").new()
var upgrade_manager

var node_buttons: Dictionary = {}
var selected_node_id: String = ""

func _ready():
	upgrade_manager = get_node("/root/UpgradeManager")
	upgrade_data._ready()
	_create_upgrade_tree()
	_update_all_nodes()
	
	if upgrade_manager:
		upgrade_manager.upgrade_purchased.connect(_on_upgrade_purchased)

func _create_upgrade_tree():
	var tree_container = $ScrollContainer/TreeContainer
	
	_draw_connections()
	
	var nodes = upgrade_data.get_all_nodes()
	for node_id in nodes:
		var node = nodes[node_id]
		_create_node_button(node, tree_container)

func _create_node_button(node, container):
	var button = Button.new()
	button.custom_minimum_size = Vector2(120, 100)
	button.position = node.position
	button.name = node.id
	
	var vbox = VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	button.add_child(vbox)
	
	var name_label = Label.new()
	name_label.text = node.name
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.add_theme_font_size_override("font_size", 12)
	vbox.add_child(name_label)
	
	var cost_label = Label.new()
	cost_label.text = str(node.cost) + " pts"
	cost_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cost_label.add_theme_font_size_override("font_size", 10)
	vbox.add_child(cost_label)
	
	button.pressed.connect(_on_node_pressed.bind(node.id))
	container.add_child(button)
	node_buttons[node.id] = button
	
	_update_node_appearance(node.id)

func _draw_connections():
	if not has_node("ScrollContainer/TreeContainer/ConnectionLines"):
		var lines = Node2D.new()
		lines.name = "ConnectionLines"
		lines.z_index = -1
		$ScrollContainer/TreeContainer.add_child(lines)
	
	var lines = $ScrollContainer/TreeContainer/ConnectionLines
	for child in lines.get_children():
		child.queue_free()
	
	var connections = upgrade_data.get_node_connections()
	for conn in connections:
		var from_node = upgrade_data.get_upgrade_node(conn.from)
		var to_node = upgrade_data.get_upgrade_node(conn.to)
		
		if from_node and to_node:
			var line = Line2D.new()
			line.add_point(from_node.position + Vector2(60, 50))
			line.add_point(to_node.position + Vector2(60, 50))
			line.width = 3
			line.default_color = Color(0.5, 0.5, 0.5, 0.5)
			lines.add_child(line)

func _update_node_appearance(node_id: String):
	if not node_buttons.has(node_id):
		return
	
	var button = node_buttons[node_id]
	var node = upgrade_data.get_upgrade_node(node_id)
	var is_unlocked = upgrade_manager.is_upgrade_unlocked(node_id)
	var can_unlock = upgrade_manager.can_unlock_upgrade(node_id, node.prerequisites, node.cost)
	
	if is_unlocked:
		button.modulate = Color(0.5, 1.0, 0.5)
		button.disabled = true
	elif can_unlock:
		button.modulate = Color(1.0, 1.0, 0.5)
		button.disabled = false
	else:
		button.modulate = Color(0.5, 0.5, 0.5)
		button.disabled = true

func _update_all_nodes():
	for node_id in node_buttons:
		_update_node_appearance(node_id)
	_update_info_panel()

func _on_node_pressed(node_id: String):
	selected_node_id = node_id
	_update_info_panel()

func _update_info_panel():
	if not has_node("InfoPanel"):
		return
	
	var info_panel = $InfoPanel
	
	if selected_node_id.is_empty():
		info_panel.visible = false
		return
	
	info_panel.visible = true
	var node = upgrade_data.get_upgrade_node(selected_node_id)
	
	if node:
		$InfoPanel/VBoxContainer/TitleLabel.text = node.name
		$InfoPanel/VBoxContainer/DescriptionLabel.text = node.description
		$InfoPanel/VBoxContainer/CostLabel.text = "Cost: " + str(node.cost) + " points"
		$InfoPanel/VBoxContainer/PointsLabel.text = "Available: " + str(upgrade_manager.get_upgrade_points()) + " points"
		
		var can_unlock = upgrade_manager.can_unlock_upgrade(node.id, node.prerequisites, node.cost)
		var is_unlocked = upgrade_manager.is_upgrade_unlocked(node.id)
		
		$InfoPanel/VBoxContainer/UnlockButton.visible = not is_unlocked
		$InfoPanel/VBoxContainer/UnlockButton.disabled = not can_unlock
		
		if is_unlocked:
			$InfoPanel/VBoxContainer/StatusLabel.text = "UNLOCKED"
			$InfoPanel/VBoxContainer/StatusLabel.modulate = Color(0.5, 1.0, 0.5)
		elif can_unlock:
			$InfoPanel/VBoxContainer/StatusLabel.text = "Available"
			$InfoPanel/VBoxContainer/StatusLabel.modulate = Color(1.0, 1.0, 0.5)
		else:
			$InfoPanel/VBoxContainer/StatusLabel.text = "Locked"
			$InfoPanel/VBoxContainer/StatusLabel.modulate = Color(1.0, 0.5, 0.5)

func _on_unlock_button_pressed():
	if selected_node_id.is_empty():
		return
	
	var node = upgrade_data.get_upgrade_node(selected_node_id)
	if node and upgrade_manager.purchase_upgrade(node.id, node.cost):
		_update_all_nodes()

func _on_upgrade_purchased(upgrade_id: String):
	_update_all_nodes()

func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://scenes/menu.tscn")

func _on_reset_button_pressed():
	upgrade_manager.reset_progress()
	_update_all_nodes()
