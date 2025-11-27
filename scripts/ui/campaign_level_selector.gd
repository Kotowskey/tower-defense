extends Control

signal level_selected(level_number)
signal back_pressed

var mode_manager

func _ready():
	mode_manager = get_node_or_null("/root/GameModeManager")
	populate_levels()
	
	if has_node("MarginContainer/VBoxContainer/BackButton"):
		$MarginContainer/VBoxContainer/BackButton.connect("pressed", Callable(self, "_on_back_pressed"))

func populate_levels():
	if not has_node("MarginContainer/VBoxContainer/LevelGrid"):
		return
	
	var grid = $MarginContainer/VBoxContainer/LevelGrid
	
	for child in grid.get_children():
		child.queue_free()
	
	var levels = CampaignLevel.get_campaign_levels()
	var highest_unlocked = mode_manager.get_highest_unlocked_level() if mode_manager else 1
	
	for level_data in levels:
		var level_button = Button.new()
		level_button.text = "Level " + str(level_data.level_number) + "\n" + level_data.level_name
		level_button.custom_minimum_size = Vector2(350, 150)
		
		var is_unlocked = level_data.level_number <= highest_unlocked
		
		if is_unlocked:
			level_button.connect("pressed", Callable(self, "_on_level_pressed").bind(level_data.level_number))
		else:
			level_button.disabled = true
			level_button.text += "\n[LOCKED]"
			level_button.modulate = Color(0.5, 0.5, 0.5, 1)
		
		grid.add_child(level_button)

func _on_level_pressed(level_number: int):
	if mode_manager:
		mode_manager.set_campaign_level(level_number)
	emit_signal("level_selected", level_number)

func _on_back_pressed():
	emit_signal("back_pressed")
