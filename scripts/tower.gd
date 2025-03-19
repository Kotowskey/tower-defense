extends Node2D
var tower_cost = 100
var tower_range = 300
var tower_damage = 10
var tower_fire_rate = 1.0
var can_fire = true
var target = null
var detection_area = null  

func _ready():
	# Utworzenie obszaru wykrywania wrogów
	if not has_node("DetectionArea"):
		var area = Area2D.new()
		area.name = "DetectionArea"
		add_child(area)
		
		var shape = CollisionShape2D.new()
		var circle = CircleShape2D.new()
		circle.radius = tower_range
		shape.shape = circle
		area.add_child(shape)
		
		area.connect("body_entered", Callable(self, "_on_detection_area_body_entered"))
		area.connect("body_exited", Callable(self, "_on_detection_area_body_exited"))
	
	
	detection_area = $DetectionArea
	
	# Ustawienie timera do strzelania
	var timer = Timer.new()
	timer.name = "FireRateTimer"
	timer.wait_time = tower_fire_rate
	timer.one_shot = false
	add_child(timer)
	timer.connect("timeout", Callable(self, "_on_fire_rate_timer_timeout"))
	timer.start()

func _process(_delta):
	if target and weakref(target).get_ref():
		# Obracanie wieży w kierunku celu
		var direction = target.global_position - global_position
		$"Basic-tower-top".rotation = direction.angle() + PI/2

func _on_detection_area_body_entered(body):
	# Sprawdzenie czy to wróg
	var parent = body.get_parent()
	if parent.has_method("take_damage") and not target:
		target = parent

func _on_detection_area_body_exited(body):
	# Sprawdzenie czy to aktualny cel
	var parent = body.get_parent()
	if target == parent:
		target = null
		# dodać szukanie nowego celu w obszarze

func _on_fire_rate_timer_timeout():
	if target and weakref(target).get_ref() and can_fire:
		fire_at_target()

func fire_at_target():
	if target.has_method("take_damage"):
		# Efekt wizualny strzału
		var line = Line2D.new()
		line.width = 2
		line.default_color = Color(1, 0, 0)  # Czerwona linia
		line.add_point(Vector2.ZERO)
		line.add_point(target.global_position - global_position)
		add_child(line)
		
		# Animacja znikania linii
		var tween = create_tween()
		tween.tween_property(line, "modulate", Color(1, 1, 1, 0), 0.2)
		tween.tween_callback(func(): line.queue_free())
		
		# Zadawanie obrażeń
		var killed = target.take_damage(tower_damage)
		if killed:
			target = null
