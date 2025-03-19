extends CharacterBody2D

signal enemy_died
signal enemy_escaped

var path: Path2D
var path_follow: PathFollow2D
var speed = 100
var max_health = 100
var current_health = max_health
var value = 25  # Ilość pieniędzy za zabicie przeciwnika

func _ready():
	current_health = max_health

func _process(delta):
	if path_follow:
		path_follow.progress += speed * delta
		position = path_follow.global_position
		
		# Sprawdź czy przeciwnik dotarł do końca ścieżki
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
