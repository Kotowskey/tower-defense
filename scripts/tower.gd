extends Node2D

@export var tower_cost: int = 100
@export var tower_range: float = 300.0
@export var tower_damage: int = 10
@export var tower_fire_rate: float = 1.0

var can_fire: bool = true
var target = null
var detection_area = null

func _ready():
	# Ładowanie sceny DetectionArea
	if not has_node("Node2D"):
		var detection_scene = load("res://scenes/detection_area.tscn")
		var area_node = detection_scene.instantiate()
		add_child(area_node)
		
		# Dostosuj promień do wartości tower_range
		var area = area_node.get_node("Area2D")
		var shape = area.get_node("CollisionShape2D").shape
		shape.radius = tower_range
		
		# Podłącz sygnały
		area.connect("body_entered", Callable(self, "_on_detection_area_body_entered"))
		area.connect("body_exited", Callable(self, "_on_detection_area_body_exited"))
	
	detection_area = $Node2D/Area2D
	
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
		
		# Odtwarzanie dźwięku jeśli istnieje AudioStreamPlayer
		if has_node("PopSound"):
			$PopSound.play()
		
		# Zadawanie obrażeń
		var killed = target.take_damage(tower_damage)
		if killed:
			target = null
