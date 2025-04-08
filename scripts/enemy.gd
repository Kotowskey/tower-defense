extends Node2D

signal enemy_died
signal enemy_escaped

@export var path: Path2D
@export var path_follow: PathFollow2D
@export var speed: float = 100
@export var max_health: int = 100
@export var value: int = 25

var current_health: int
var current_speed: float
var slow_factor: float = 1.0
var slow_timer: Timer = null

func _ready():
	current_health = max_health
	current_speed = speed
	
	slow_timer = Timer.new()
	slow_timer.one_shot = true
	add_child(slow_timer)
	slow_timer.connect("timeout", Callable(self, "_on_slow_timer_timeout"))

func _process(delta):
	if path_follow:
		path_follow.progress += current_speed * delta
		position = path_follow.global_position
		
		if path_follow.progress_ratio >= 0.99:
			emit_signal("enemy_escaped")
			queue_free()

func take_damage(damage):
	current_health -= damage
	if current_health <= 0:
		emit_signal("enemy_died")
		queue_free()
		return true
	return false

func apply_slow(factor, duration):
	slow_factor = min(slow_factor, factor) 
	current_speed = speed * slow_factor
	
	slow_timer.wait_time = duration
	slow_timer.start()
	
	$CharacterBody2D/Sprite2D.modulate = Color(0.5, 0.5, 1)

func _on_slow_timer_timeout():
	slow_factor = 1.0
	current_speed = speed
	$CharacterBody2D/Sprite2D.modulate = Color(1, 1, 1)
