extends Control

var talent_manager

@onready var talent_points_label = $Panel/VBoxContainer/Header/TalentPointsLabel
@onready var talent_tree_container = $Panel/VBoxContainer/ScrollContainer/TalentTreeContainer
@onready var close_button = $Panel/VBoxContainer/Header/CloseButton
@onready var reset_button = $Panel/VBoxContainer/Header/ResetButton

var talent_buttons: Dictionary = {}

func _ready():
	close_button.pressed.connect(_on_close_pressed)
	reset_button.pressed.connect(_on_reset_pressed)
	
	if has_node("/root/TalentManager"):
		talent_manager = get_node("/root/TalentManager")
	else:
		talent_manager = load("res://scripts/managers/talent_manager.gd").new()
		talent_manager.name = "TalentManager"
		get_tree().root.add_child(talent_manager)
	
	talent_manager.talent_points_changed.connect(_on_talent_points_changed)
	talent_manager.talent_unlocked.connect(_on_talent_unlocked)
	
	build_talent_tree()
	update_talent_points_display()

func build_talent_tree():
	for child in talent_tree_container.get_children():
		child.queue_free()
	
	talent_buttons.clear()
	
	var tiers: Dictionary = {}
	for talent_id in talent_manager.talents:
		var talent = talent_manager.talents[talent_id]
		var tier = talent["tier"]
		if not tiers.has(tier):
			tiers[tier] = []
		tiers[tier].append(talent_id)
	
	var tier_keys = tiers.keys()
	tier_keys.sort()
	
	for tier in tier_keys:
		var tier_label = Label.new()
		tier_label.text = "Poziom " + str(tier)
		tier_label.add_theme_font_size_override("font_size", 24)
		tier_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		talent_tree_container.add_child(tier_label)
		
		var tier_container = HBoxContainer.new()
		tier_container.alignment = BoxContainer.ALIGNMENT_CENTER
		tier_container.add_theme_constant_override("separation", 20)
		talent_tree_container.add_child(tier_container)
		
		for talent_id in tiers[tier]:
			var talent = talent_manager.talents[talent_id]
			var talent_button = create_talent_button(talent_id, talent)
			tier_container.add_child(talent_button)
			talent_buttons[talent_id] = talent_button
		
		var spacer = Control.new()
		spacer.custom_minimum_size = Vector2(0, 30)
		talent_tree_container.add_child(spacer)
	
	update_all_buttons()

func create_talent_button(talent_id: String, talent: Dictionary) -> Button:
	var button = Button.new()
	button.custom_minimum_size = Vector2(200, 100)
	button.text = talent["name"] + "\n" + talent["description"] + "\nKoszt: " + str(talent["cost"])
	button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	
	button.pressed.connect(_on_talent_button_pressed.bind(talent_id))
	
	return button

func _on_talent_button_pressed(talent_id: String):
	if talent_manager.unlock_talent(talent_id):
		update_all_buttons()
		update_talent_points_display()

func update_all_buttons():
	for talent_id in talent_buttons:
		var button = talent_buttons[talent_id]
		var is_unlocked = talent_manager.is_talent_unlocked(talent_id)
		var can_unlock = talent_manager.can_unlock_talent(talent_id)
		
		button.disabled = is_unlocked or not can_unlock
		
		if is_unlocked:
			button.modulate = Color(0.5, 1.0, 0.5)
		elif can_unlock:
			button.modulate = Color(1.0, 1.0, 1.0)
		else:
			button.modulate = Color(0.5, 0.5, 0.5)

func update_talent_points_display():
	talent_points_label.text = "Punkty talentów: " + str(talent_manager.talent_points)

func _on_talent_points_changed(points):
	update_talent_points_display()
	update_all_buttons()

func _on_talent_unlocked(talent_id):
	update_all_buttons()

func _on_close_pressed():
	queue_free()

func _on_reset_pressed():
	talent_manager.reset_talents()
	update_all_buttons()
	update_talent_points_display()
