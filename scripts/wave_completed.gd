extends Control

func _ready():
	var timer = Timer.new()
	timer.wait_time = 3.0
	timer.one_shot = true
	add_child(timer)
	timer.connect("timeout", Callable(self, "_on_timer_timeout"))
	timer.start()

func set_wave_info(wave_number, reward):
	var is_boss_wave = (wave_number % 5 == 0)
	
	if has_node("ContentContainer/WaveTitle"):
		var wave_text = "WAVE " + str(wave_number) + " COMPLETE!"
		if is_boss_wave:
			wave_text = "BOSS WAVE " + str(wave_number) + " DEFEATED!"
		$ContentContainer/WaveTitle.text = wave_text
	
	if has_node("ContentContainer/RewardPanel/RewardContainer/Label"):
		$ContentContainer/RewardPanel/RewardContainer/Label.text = "+" + str(reward) + " Money"

func _on_timer_timeout():
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(1, 1, 1, 0), 0.5)
	tween.tween_callback(Callable(self, "queue_free"))
