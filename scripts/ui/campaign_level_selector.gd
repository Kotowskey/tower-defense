extends Control

signal level_selected(level_number)
signal back_pressed

var mode_manager

func _ready():
	mode_manager = GameModeManager
	populate_levels()
	
	if has_node("MarginContainer/VBoxContainer/ButtonContainer/BackButton"):
		$MarginContainer/VBoxContainer/ButtonContainer/BackButton.connect("pressed", Callable(self, "_on_back_pressed"))

func populate_levels():
	if not has_node("MarginContainer/VBoxContainer/ScrollContainer/CenterContainer/LevelGrid"):
		return
	
	var grid = $MarginContainer/VBoxContainer/ScrollContainer/CenterContainer/LevelGrid
	
	for child in grid.get_children():
		child.queue_free()
	
	var levels = CampaignLevel.get_campaign_levels()
	var highest_unlocked = mode_manager.get_highest_unlocked_level() if mode_manager else 1
	
	for level_data in levels:
		var level_container = create_level_button(level_data, highest_unlocked)
		grid.add_child(level_container)

func create_level_button(level_data, highest_unlocked: int) -> Control:
	var panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(280, 180)
	
	# Tło panelu
	var style_box = StyleBoxFlat.new()
	var is_unlocked = level_data.level_number <= highest_unlocked
	
	if is_unlocked:
		style_box.bg_color = Color(0.15, 0.15, 0.25, 0.95)
		style_box.border_color = Color(0.3, 0.5, 0.8, 1)
	else:
		style_box.bg_color = Color(0.1, 0.1, 0.15, 0.8)
		style_box.border_color = Color(0.3, 0.3, 0.3, 0.5)
	
	style_box.border_width_left = 2
	style_box.border_width_top = 2
	style_box.border_width_right = 2
	style_box.border_width_bottom = 2
	style_box.corner_radius_top_left = 8
	style_box.corner_radius_top_right = 8
	style_box.corner_radius_bottom_left = 8
	style_box.corner_radius_bottom_right = 8
	
	panel.add_theme_stylebox_override("panel", style_box)
	
	# VBoxContainer dla treści
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	panel.add_child(vbox)
	
	# Numer poziomu
	var level_number_label = Label.new()
	level_number_label.text = "LEVEL " + str(level_data.level_number)
	level_number_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	level_number_label.add_theme_font_size_override("font_size", 20)
	if is_unlocked:
		level_number_label.add_theme_color_override("font_color", Color(1, 0.8, 0.2, 1))
	else:
		level_number_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5, 1))
	vbox.add_child(level_number_label)
	
	# Nazwa poziomu
	var level_name_label = Label.new()
	level_name_label.text = level_data.level_name
	level_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	level_name_label.add_theme_font_size_override("font_size", 18)
	level_name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	if is_unlocked:
		level_name_label.add_theme_color_override("font_color", Color(0.9, 0.9, 1, 1))
	else:
		level_name_label.add_theme_color_override("font_color", Color(0.4, 0.4, 0.4, 1))
	vbox.add_child(level_name_label)
	
	# Spacer
	var spacer = Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(spacer)
	
	# Status/Przycisk
	var button = Button.new()
	button.custom_minimum_size = Vector2(0, 50)
	
	if is_unlocked:
		button.text = "START"
		button.add_theme_font_size_override("font_size", 20)
		button.add_theme_color_override("font_color", Color(1, 1, 1, 1))
		button.add_theme_color_override("font_hover_color", Color(1, 0.8, 0.2, 1))
		button.connect("pressed", Callable(self, "_on_level_pressed").bind(level_data.level_number))
		
		# Hover efekt
		button.mouse_entered.connect(func():
			var tween = create_tween()
			tween.tween_property(panel, "modulate", Color(1.2, 1.2, 1.2, 1), 0.2)
		)
		button.mouse_exited.connect(func():
			var tween = create_tween()
			tween.tween_property(panel, "modulate", Color(1, 1, 1, 1), 0.2)
		)
	else:
		button.text = "🔒 LOCKED"
		button.disabled = true
		button.add_theme_font_size_override("font_size", 18)
		button.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5, 1))
		panel.modulate = Color(0.7, 0.7, 0.7, 1)
	
	vbox.add_child(button)
	
	return panel

func _on_level_pressed(level_number: int):
	if mode_manager:
		mode_manager.set_campaign_level(level_number)
	emit_signal("level_selected", level_number)

func _on_back_pressed():
	emit_signal("back_pressed")
