extends Control

func _ready():
	custom_minimum_size = Vector2(300, 100)
	size = Vector2(300, 100)
	position = Vector2(
		(get_viewport().size.x - size.x) / 2,
		get_viewport().size.y / 3
	)
	
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(1, 1, 1, 0), 2.0)
	tween.tween_callback(func(): queue_free())

func set_wave_info(wave_number, reward):
	var is_boss_wave = (wave_number % 5 == 0)
	var wave_text = "Fala " + str(wave_number)
	
	if is_boss_wave:
		wave_text += " (BOSS)"
	
	wave_text += " zakończona!\n+" + str(reward) + " Kasy"
	
	$Label.text = wave_text
