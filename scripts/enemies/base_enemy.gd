extends Node2D
class_name BaseEnemy

signal enemy_died(enemy_type)
signal enemy_escaped

@export var path: Path2D
@export var path_follow: PathFollow2D
@export var speed: float = 50
@export var max_health: int = 100
@export var value: int = 25

var current_health: int
var current_speed: float
var slow_factor: float = 1.0
var slow_timer: Timer = null
var health_bar: ProgressBar
var enemy_type: int = 0 

func _ready():
	current_health = max_health
	current_speed = speed
	
	setup_slow_timer()
	setup_health_bar()

func setup_slow_timer():
	slow_timer = Timer.new()
	slow_timer.one_shot = true
	add_child(slow_timer)
	slow_timer.connect("timeout", Callable(self, "_on_slow_timer_timeout"))

func setup_health_bar():
	health_bar = $HealthBar
	if health_bar:
		health_bar.max_value = max_health
		health_bar.value = current_health
		health_bar.show()

func _process(delta):
	move_along_path(delta)

func move_along_path(delta):
	if path_follow:
		path_follow.progress += current_speed * delta
		position = path_follow.global_position
		
		if path_follow.progress_ratio >= 0.99:
			emit_signal("enemy_escaped")
			queue_free()

func take_damage(damage):
	current_health -= damage
	
	if health_bar:
		health_bar.value = current_health
	
	if current_health <= 0:
		emit_signal("enemy_died", enemy_type)
		queue_free()
		return true
	return false

func apply_slow(factor, duration):
	slow_factor = min(slow_factor, factor)
	current_speed = speed * slow_factor
	
	slow_timer.wait_time = duration
	slow_timer.start()
	
	$CharacterBody2D/Sprite2D.modulate = Color(0.5, 0.5, 1)
	
	if health_bar:
		health_bar.modulate = Color(0.8, 0.8, 1.2)

func _on_slow_timer_timeout():
	slow_factor = 1.0
	current_speed = speed
	$CharacterBody2D/Sprite2D.modulate = Color(1, 1, 1)
	
	if health_bar:
		health_bar.modulate = Color(1, 1, 1)

func get_enemy_stats() -> Dictionary:
	return {
		"max_health": max_health,
		"current_health": current_health,
		"speed": speed,
		"value": value,
		"type": enemy_type
	}
