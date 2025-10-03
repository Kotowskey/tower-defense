extends Node2D

signal enemy_died
signal enemy_escaped

@export var path: Path2D
@export var path_follow: PathFollow2D
@export var speed: float = 100
@export var max_health: int = 100
@export var value: int = 25
@export var is_boss: bool = false
@export var boss_type: int = 0

var current_health: int
var current_speed: float
var slow_factor: float = 1.0
var slow_timer: Timer = null
var health_bar: ProgressBar

func _ready():
	current_health = max_health
	current_speed = speed
	
	slow_timer = Timer.new()
	slow_timer.one_shot = true
	add_child(slow_timer)
	slow_timer.connect("timeout", Callable(self, "_on_slow_timer_timeout"))
	
	if is_boss:
		setup_boss_properties()
	
	setup_health_bar()

func setup_health_bar():
	health_bar = $HealthBar
	if health_bar:
		health_bar.max_value = max_health
		health_bar.value = current_health
		health_bar.show()

func setup_boss_properties():
	match boss_type:
		0: # Tank Boss
			max_health = 500
			speed = 80
			value = 200
			scale = Vector2(1.5, 1.5)
			$CharacterBody2D/Sprite2D.modulate = Color(0.8, 0.2, 0.2)
		
		1: # Speed Boss
			max_health = 200
			speed = 300
			value = 150
			scale = Vector2(1.2, 1.2)
			$CharacterBody2D/Sprite2D.modulate = Color(0.2, 0.8, 0.2)
		
		2: # Shield Boss
			max_health = 350
			speed = 120
			value = 250
			scale = Vector2(1.4, 1.4)
			$CharacterBody2D/Sprite2D.modulate = Color(0.2, 0.2, 0.8)
	
	current_health = max_health
	current_speed = speed

func _process(delta):
	if path_follow:
		path_follow.progress += current_speed * delta
		position = path_follow.global_position
		
		if path_follow.progress_ratio >= 0.99:
			emit_signal("enemy_escaped")
			queue_free()

func take_damage(damage):
	if is_boss and boss_type == 2: # shield boss mniejszy damage
		damage = int(damage * 0.7)
	
	current_health -= damage
	
	if health_bar:
		health_bar.value = current_health
	
	if current_health <= 0:
		emit_signal("enemy_died")
		queue_free()
		return true
	return false

func apply_slow(factor, duration):
	var slow_resistance = 1.0
	if is_boss:
		slow_resistance = 0.5 
	
	slow_factor = min(slow_factor, factor * slow_resistance + (1.0 - slow_resistance))
	current_speed = speed * slow_factor
	
	slow_timer.wait_time = duration * slow_resistance
	slow_timer.start()
	
	$CharacterBody2D/Sprite2D.modulate = Color(0.5, 0.5, 1) if not is_boss else $CharacterBody2D/Sprite2D.modulate * Color(0.8, 0.8, 1.2)
	

	if health_bar:
		health_bar.modulate = Color(0.8, 0.8, 1.2)

func _on_slow_timer_timeout():
	slow_factor = 1.0
	current_speed = speed
	$CharacterBody2D/Sprite2D.modulate = Color(1, 1, 1)
	
	if health_bar:
		health_bar.modulate = Color(1, 1, 1)
