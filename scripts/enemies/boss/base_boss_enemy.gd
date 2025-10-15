extends BaseEnemy
class_name BaseBossEnemy

var boss_type: int = 0  # For backwards compatibility

func _ready():
	scale = Vector2(1.5, 1.5)
	super._ready()

func apply_slow(factor, duration):
	# Bosses have slow resistance
	var slow_resistance = 0.5
	var effective_factor = factor * slow_resistance + (1.0 - slow_resistance)
	var effective_duration = duration * slow_resistance
	
	slow_factor = min(slow_factor, effective_factor)
	current_speed = speed * slow_factor
	
	slow_timer.wait_time = effective_duration
	slow_timer.start()
	
	$CharacterBody2D/Sprite2D.modulate = $CharacterBody2D/Sprite2D.modulate * Color(0.8, 0.8, 1.2)
	
	if health_bar:
		health_bar.modulate = Color(0.8, 0.8, 1.2)
