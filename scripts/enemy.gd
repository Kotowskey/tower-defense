extends Node2D

signal enemy_died
signal enemy_escaped

@export var path: Path2D
@export var path_follow: PathFollow2D
@export var speed: float = 100
@export var max_health: int = 100
@export var value: int = 25

var current_health: int

func _ready():
	current_health = max_health

func _process(delta):
	if path_follow:
		path_follow.progress += speed * delta
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
