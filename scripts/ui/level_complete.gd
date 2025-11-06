extends Control

signal next_level_pressed
signal main_menu_pressed

func _ready():
	$Panel/MarginContainer/VBoxContainer/NextButton.connect("pressed", Callable(self, "_on_next_pressed"))
	$Panel/MarginContainer/VBoxContainer/MainMenuButton.connect("pressed", Callable(self, "_on_main_menu_pressed"))

func set_level_info(level_number: int, bonus_money: int = 0):
	$Panel/MarginContainer/VBoxContainer/LevelInfo.text = "Level " + str(level_number) + " Complete!"
	
	if bonus_money > 0:
		if not $Panel/MarginContainer/VBoxContainer.has_node("BonusLabel"):
			var bonus_label = Label.new()
			bonus_label.name = "BonusLabel"
			bonus_label.text = "Bonus Money: +" + str(bonus_money)
			bonus_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			bonus_label.add_theme_font_size_override("font_size", 18)
			bonus_label.add_theme_color_override("font_color", Color(0.3, 1.0, 0.3, 1))
			$Panel/MarginContainer/VBoxContainer.add_child(bonus_label)
			$Panel/MarginContainer/VBoxContainer.move_child(bonus_label, 1)

func _on_next_pressed():
	print("Next level button pressed!")
	emit_signal("next_level_pressed")

func _on_main_menu_pressed():
	print("Main menu button pressed from level complete!")
	emit_signal("main_menu_pressed")
