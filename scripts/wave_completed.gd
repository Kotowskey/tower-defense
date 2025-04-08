extends Control

func _ready():
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(1, 1, 1, 0), 2.0)
	tween.tween_callback(func(): queue_free())

func set_wave_info(wave_number, reward):
	$Label.text = "Fala " + str(wave_number) + " zakończona!\n+" + str(reward) + " Kasy"