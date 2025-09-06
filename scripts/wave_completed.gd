extends Control

func _ready():
	# Automatically hide after a few seconds
	var timer = Timer.new()
	timer.wait_time = 3.0
	timer.one_shot = true
	add_child(timer)
	timer.connect("timeout", Callable(self, "_on_timer_timeout"))
	timer.start()

func set_wave_info(wave_number, reward):
	var is_boss_wave = (wave_number % 5 == 0)
	var wave_text = "Fala " + str(wave_number)
	
	if is_boss_wave:
		wave_text += " (BOSS)"
	
	wave_text += " zakończona!\n+" + str(reward) + " Kasy"
	
	$Label.text = wave_text

func _on_timer_timeout():
	# Fade out animation
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(1, 1, 1, 0), 0.5)
	tween.tween_callback(Callable(self, "queue_free"))
