class_name MapSelector
extends Control


signal map_selected(map_data: MapData)
signal back_pressed

var available_maps: Array[MapData] = []
var selected_map_data: MapData = null

var map_grid: GridContainer
var map_name_label: Label
var map_description_label: Label
var difficulty_label: Label
var preview_texture_rect: TextureRect
var no_preview_label: Label
var select_button: TextureButton

func _ready():
	_initialize_maps()
	_setup_ui_references()
	_create_map_buttons()

func _initialize_maps():
	available_maps.clear()
	
	var map1 = MapData.new(
		"Classic Route",
		"Standard map with a simple path.\nGood for beginners.",
		"res://scenes/map.tscn",
		"res://assets/maps/map1.png",
		1,
		false
	)
	available_maps.append(map1)
	
	var map2 = MapData.new(
		"Winding Road",
		"Advanced map with many turns.\nRequires strategic planning.",
		"res://scenes/map2.tscn",
		"res://assets/maps/map2.png",
		3,
		false
	)
	available_maps.append(map2)

func _setup_ui_references():
	if has_node("Panel/VBoxContainer/MapsScrollContainer/MapGrid"):
		map_grid = $Panel/VBoxContainer/MapsScrollContainer/MapGrid
	
	if has_node("Panel/VBoxContainer/DetailsPanel/DetailsContainer/InfoPanel/MapNameLabel"):
		map_name_label = $Panel/VBoxContainer/DetailsPanel/DetailsContainer/InfoPanel/MapNameLabel
	
	if has_node("Panel/VBoxContainer/DetailsPanel/DetailsContainer/InfoPanel/DescriptionLabel"):
		map_description_label = $Panel/VBoxContainer/DetailsPanel/DetailsContainer/InfoPanel/DescriptionLabel
	
	if has_node("Panel/VBoxContainer/DetailsPanel/DetailsContainer/InfoPanel/DifficultyLabel"):
		difficulty_label = $Panel/VBoxContainer/DetailsPanel/DetailsContainer/InfoPanel/DifficultyLabel
	
	if has_node("Panel/VBoxContainer/DetailsPanel/DetailsContainer/PreviewPanel/PreviewRect"):
		preview_texture_rect = $Panel/VBoxContainer/DetailsPanel/DetailsContainer/PreviewPanel/PreviewRect
	
	if has_node("Panel/VBoxContainer/DetailsPanel/DetailsContainer/PreviewPanel/NoPreviewLabel"):
		no_preview_label = $Panel/VBoxContainer/DetailsPanel/DetailsContainer/PreviewPanel/NoPreviewLabel
	
	if has_node("Panel/VBoxContainer/ButtonsContainer/SelectButton"):
		select_button = $Panel/VBoxContainer/ButtonsContainer/SelectButton
		select_button.disabled = true
		select_button.connect("pressed", Callable(self, "_on_select_button_pressed"))
	
	if has_node("Panel/VBoxContainer/ButtonsContainer/BackButton"):
		var back_button = $Panel/VBoxContainer/ButtonsContainer/BackButton
		back_button.connect("pressed", Callable(self, "_on_back_button_pressed"))

func _create_map_buttons():
	if not map_grid:
		return
	
	for child in map_grid.get_children():
		child.queue_free()
	
	for map_data in available_maps:
		var map_button = _create_map_card(map_data)
		map_grid.add_child(map_button)

func _create_map_card(map_data: MapData) -> Control:
	var card = PanelContainer.new()
	card.custom_minimum_size = Vector2(280, 220)
	
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_bottom", 10)
	card.add_child(margin)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)
	margin.add_child(vbox)
	
	var preview_container = AspectRatioContainer.new()
	preview_container.ratio = 16.0 / 9.0
	preview_container.stretch_mode = AspectRatioContainer.STRETCH_FIT
	vbox.add_child(preview_container)
	
	var preview = TextureRect.new()
	preview.expand_mode = TextureRect.EXPAND_FIT_WIDTH
	preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	
	if map_data.preview_image_path != "" and ResourceLoader.exists(map_data.preview_image_path):
		preview.texture = load(map_data.preview_image_path)
	
	preview_container.add_child(preview)
	
	var name_label = Label.new()
	name_label.text = map_data.get_display_name()
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.add_theme_font_size_override("font_size", 18)
	vbox.add_child(name_label)
	
	var diff_label = Label.new()
	diff_label.text = "Difficulty: " + map_data.get_difficulty_stars()
	diff_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	diff_label.add_theme_font_size_override("font_size", 14)
	vbox.add_child(diff_label)
	
	var button = Button.new()
	button.text = "SELECT" if map_data.is_available() else "LOCKED"
	button.disabled = not map_data.is_available()
	button.connect("pressed", Callable(self, "_on_map_card_pressed").bind(map_data))
	vbox.add_child(button)
	
	return card

func _on_map_card_pressed(map_data: MapData):
	selected_map_data = map_data
	_update_details_panel(map_data)
	
	if select_button:
		select_button.disabled = false

func _update_details_panel(map_data: MapData):
	if map_name_label:
		map_name_label.text = map_data.get_display_name()
	
	if map_description_label:
		map_description_label.text = map_data.get_description()
	
	if difficulty_label:
		difficulty_label.text = "Difficulty: " + map_data.get_difficulty_stars()
	
	if preview_texture_rect:
		if map_data.preview_image_path != "" and ResourceLoader.exists(map_data.preview_image_path):
			preview_texture_rect.texture = load(map_data.preview_image_path)
			if no_preview_label:
				no_preview_label.visible = false
		else:
			preview_texture_rect.texture = null
			if no_preview_label:
				no_preview_label.visible = true

func _on_select_button_pressed():
	if selected_map_data:
		emit_signal("map_selected", selected_map_data)

func _on_back_button_pressed():
	emit_signal("back_pressed")

func get_selected_map_path() -> String:
	if selected_map_data:
		return selected_map_data.map_path
	return ""
