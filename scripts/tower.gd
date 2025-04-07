extends Node2D

@export var tower_type: int = 0 # Typ wieży (0=Basic, 1=Rocket, 2=Sniper, 3=Ice)
@export var tower_level: int = 1 

@export var tower_cost: int = 100
@export var tower_range: float = 300.0
@export var tower_damage: int = 10
@export var tower_fire_rate: float = 1.0
var slow_factor: float = 0
var slow_duration: float = 0
var tower_name: String = "Basic Tower"
var targets = [] 

var can_fire: bool = true
var target = null
var detection_area = null

func _ready():
	setup_tower_properties()
	
	if not has_node("Node2D"):
		var detection_scene = load("res://scenes/detection_area.tscn")
		var area_node = detection_scene.instantiate()
		add_child(area_node)
		
		var area = area_node.get_node("Area2D")
		var shape = area.get_node("CollisionShape2D").shape
		shape.radius = tower_range
		
		if tower_type == 1: # Rocket Tower
			area.connect("body_entered", Callable(self, "_on_detection_area_body_entered_area"))
			area.connect("body_exited", Callable(self, "_on_detection_area_body_exited_area"))
		else:
			area.connect("body_entered", Callable(self, "_on_detection_area_body_entered"))
			area.connect("body_exited", Callable(self, "_on_detection_area_body_exited"))
	
	detection_area = $Node2D/Area2D
	
	# Timera do strzelania
	var timer = Timer.new()
	timer.name = "FireRateTimer"
	timer.wait_time = tower_fire_rate
	timer.one_shot = false
	add_child(timer)
	timer.connect("timeout", Callable(self, "_on_fire_rate_timer_timeout"))
	timer.start()

func setup_tower_properties():
	match tower_type:
		0: # Basic Tower
			tower_name = "Basic Tower"
			tower_cost = 100
			tower_range = 300.0
			tower_damage = 10
			tower_fire_rate = 1.0
		
		1: # Rocket Tower
			tower_name = "Rocket Tower"
			tower_cost = 200
			tower_range = 250.0
			tower_damage = 5
			tower_fire_rate = 1.5
			
			if has_node("Basic-tower-top"):
				var texture = load("res://assets/towers/rocket-tower-top.svg") 
				if texture:
					$"Basic-tower-top".texture = texture
		
		2: # Sniper Tower
			tower_name = "Sniper Tower"
			tower_cost = 300
			tower_range = 500.0
			tower_damage = 30
			tower_fire_rate = 2.0
			
			if has_node("Basic-tower-top"):
				var texture = load("res://assets/towers/sniper-tower-top.svg")
				if texture:
					$"Basic-tower-top".texture = texture
		
		3: # Ice Tower
			tower_name = "Ice Tower"
			tower_cost = 150
			tower_range = 250.0
			tower_damage = 5
			tower_fire_rate = 1.0
			slow_factor = 0.5
			slow_duration = 2.0
			
			if has_node("Basic-tower-top"):
				var texture = load("res://assets/towers/ice-tower-top.svg")
				if texture:
					$"Basic-tower-top".texture = texture

func _process(_delta):
	if tower_type == 1: # Area Tower
		pass # Wieża obszarowa nie obraca się
	elif target and weakref(target).get_ref():
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
		# Szukanie nowego celu w obszarze
		if detection_area:
			var bodies = detection_area.get_overlapping_bodies()
			for b in bodies:
				var p = b.get_parent()
				if p.has_method("take_damage"):
					target = p
					break

func _on_detection_area_body_entered_area(body):
	# Dla wieży obszarowej dodajemy wszystkie cele do listy
	var parent = body.get_parent()
	if parent.has_method("take_damage") and not targets.has(parent):
		targets.append(parent)

func _on_detection_area_body_exited_area(body):
	# Dla wieży obszarowej usuwamy cel z listy
	var parent = body.get_parent()
	if targets.has(parent):
		targets.erase(parent)

func _on_fire_rate_timer_timeout():
	if tower_type == 1: # Area Tower
		fire_at_all_targets()
	elif target and weakref(target).get_ref() and can_fire:
		fire_at_target(target)

func fire_at_target(enemy_target):
	if enemy_target.has_method("take_damage"):
		# Efekt wizualny strzału
		var line = Line2D.new()
		line.width = 2
		
		# Różne kolory dla różnych typów wież
		if tower_type == 2: # Sniper Tower
			line.default_color = Color(0, 0, 1)  # Niebieska linia
		elif tower_type == 3: # Ice Tower
			line.default_color = Color(0, 1, 1)  # Cyjanowa linia
		else:
			line.default_color = Color(1, 0, 0)  # Czerwona linia
			
		line.add_point(Vector2.ZERO)
		line.add_point(enemy_target.global_position - global_position)
		add_child(line)
		
		# Animacja znikania linii
		var tween = create_tween()
		tween.tween_property(line, "modulate", Color(1, 1, 1, 0), 0.2)
		tween.tween_callback(func(): line.queue_free())
		
		if has_node("PopSound"):
			$PopSound.play()
		
		# Zadawanie obrażeń
		var killed = enemy_target.take_damage(tower_damage)
		
		# Dla wieży spowalniającej
		if tower_type == 3 and enemy_target.has_method("apply_slow"):
			enemy_target.apply_slow(slow_factor, slow_duration)
			
		if killed:
			if tower_type != 1: # Nie dotyczy wieży obszarowej
				target = null

func fire_at_all_targets():
	# Dla wieży obszarowej - strzelamy do wszystkich celów w zasięgu
	var valid_targets = []
	
	# Sprawdzenie, które cele są nadal ważne
	for t in targets:
		if weakref(t).get_ref():
			valid_targets.append(t)
	
	targets = valid_targets
	
	if targets.size() > 0 and can_fire:
		# Efekt wizualny strzału obszarowego
		var circle = Node2D.new()
		add_child(circle)
		
		var tween = create_tween()
		tween.tween_callback(func():
			var draw_circle = func():
				var visual_effect = Node2D.new()
				visual_effect.draw.connect(func():
					draw_circle(Vector2.ZERO, tower_range, Color(1, 0.5, 0, 0.3))
				)
				circle.add_child(visual_effect)
				
				var inner_tween = create_tween()
				inner_tween.tween_property(visual_effect, "modulate", Color(1, 1, 1, 0), 0.3)
				inner_tween.tween_callback(func(): visual_effect.queue_free())
			draw_circle.call()
		)
		
		if has_node("PopSound"):
			$PopSound.play()
		
		# Zadawanie obrażeń wszystkim celom
		for t in targets:
			if t.has_method("take_damage"):
				t.take_damage(tower_damage)

# Funkcja do ulepszania wieży
func upgrade():
	tower_level += 1
	
	# Zwiększamy statystyki w zależności od typu wieży
	match tower_type:
		0: # Basic Tower
			tower_damage += 5
			tower_fire_rate *= 0.9
		1: # Rocket Tower
			tower_damage += 2
			tower_range += 25
		2: # Sniper Tower
			tower_damage += 15
		3: # Ice Tower
			slow_factor -= 0.1
			slow_duration += 0.5
	
	# Aktualizacja parametrów timera
	if has_node("FireRateTimer"):
		$FireRateTimer.wait_time = tower_fire_rate
	
	# Aktualizacja zasięgu
	if has_node("Node2D/Area2D/CollisionShape2D"):
		$Node2D/Area2D/CollisionShape2D.shape.radius = tower_range
	
	# Zwracamy koszt ulepszenia (rośnie z poziomem)
	return tower_cost * tower_level

# Funkcja do pokazywania zasięgu wieży
func show_range(show = true):
	if has_node("RangeIndicator"):
		$RangeIndicator.queue_free()
	
	if show:
		var indicator = Node2D.new()
		indicator.name = "RangeIndicator"
		add_child(indicator)
		
		# Tworzymy prosty okrąg wizualny
		var visual = Node2D.new()
		visual.draw.connect(func():
			draw_circle(Vector2.ZERO, tower_range, Color(0.5, 0.5, 1.0, 0.2))
			draw_arc(Vector2.ZERO, tower_range, 0, 2*PI, 32, Color(0.5, 0.5, 1.0, 0.5), 2.0)
		)
		indicator.add_child(visual)
