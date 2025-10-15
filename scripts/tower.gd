extends Node2D

@export var tower_type: int = 0 
@export var tower_level: int = 1 
@export var max_level: int = 5

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
		
		if tower_type == 1:
			area.connect("body_entered", Callable(self, "_on_detection_area_body_entered_area"))
			area.connect("body_exited", Callable(self, "_on_detection_area_body_exited_area"))
		else:
			area.connect("body_entered", Callable(self, "_on_detection_area_body_entered"))
			area.connect("body_exited", Callable(self, "_on_detection_area_body_exited"))
	
	detection_area = $Node2D/Area2D
	
	var timer = Timer.new()
	timer.name = "FireRateTimer"
	timer.wait_time = tower_fire_rate
	timer.one_shot = false
	add_child(timer)
	timer.connect("timeout", Callable(self, "_on_fire_rate_timer_timeout"))
	
	await get_tree().process_frame
	timer.start()

func setup_tower_properties():
	match tower_type:
		0:
			tower_name = "Basic Tower"
			tower_cost = 100
			tower_range = 300.0
			tower_damage = 10
			tower_fire_rate = 1.0
		
		1:
			tower_name = "Rocket Tower"
			tower_cost = 200
			tower_range = 250.0
			tower_damage = 5
			tower_fire_rate = 1.5
			
			if has_node("Basic-tower-top"):
				var texture = load("res://assets/kenney_top-down-tanks-redux/PNG/Default size/tank_red.png") 
				if texture:
					$"Basic-tower-top".texture = texture
		
		2:
			tower_name = "Sniper Tower"
			tower_cost = 300
			tower_range = 500.0
			tower_damage = 30
			tower_fire_rate = 2.0
			
			if has_node("Basic-tower-top"):
				var texture = load("res://assets/kenney_top-down-tanks-redux/PNG/Default size/tank_green.png")
				if texture:
					$"Basic-tower-top".texture = texture
		
		3:
			tower_name = "Ice Tower"
			tower_cost = 150
			tower_range = 250.0
			tower_damage = 5
			tower_fire_rate = 1.0
			slow_factor = 0.5
			slow_duration = 2.0
			
			if has_node("Basic-tower-top"):
				var texture = load("res://assets/kenney_top-down-tanks-redux/PNG/Default size/tank_blue.png")
				if texture:
					$"Basic-tower-top".texture = texture

func _process(_delta):
	if tower_type == 1:
		pass
	elif target and weakref(target).get_ref():
		var direction = target.global_position - global_position
		$"Basic-tower-top".rotation = direction.angle() + PI/2 + PI

func _on_detection_area_body_entered(body):
	var parent = body.get_parent()
	if parent.has_method("take_damage") and not target:
		target = parent

func _on_detection_area_body_exited(body):
	var parent = body.get_parent()
	if target == parent:
		target = null
		if detection_area:
			var bodies = detection_area.get_overlapping_bodies()
			for b in bodies:
				var p = b.get_parent()
				if p.has_method("take_damage"):
					target = p
					break

func _on_detection_area_body_entered_area(body):
	var parent = body.get_parent()
	if parent.has_method("take_damage") and not targets.has(parent):
		targets.append(parent)

func _on_detection_area_body_exited_area(body):
	var parent = body.get_parent()
	if targets.has(parent):
		targets.erase(parent)

func _on_fire_rate_timer_timeout():
	if tower_type == 1:
		fire_at_all_targets()
	elif target and weakref(target).get_ref() and can_fire:
		fire_at_target(target)

func fire_at_target(enemy_target):
	if enemy_target.has_method("take_damage"):
		var line = Line2D.new()
		line.width = 2
		
		if tower_type == 2:
			line.default_color = Color(0, 0, 1)
		elif tower_type == 3:
			line.default_color = Color(0, 1, 1)
		else:
			line.default_color = Color(1, 0, 0)
			
		line.add_point(Vector2.ZERO)
		line.add_point(enemy_target.global_position - global_position)
		add_child(line)
		
		var tween = create_tween()
		tween.tween_property(line, "modulate", Color(1, 1, 1, 0), 0.2)
		tween.tween_callback(func(): line.queue_free())
		
		if has_node("PopSound"):
			$PopSound.play()
		
		var killed = enemy_target.take_damage(tower_damage)
		
		if tower_type == 3 and enemy_target.has_method("apply_slow"):
			enemy_target.apply_slow(slow_factor, slow_duration)
			
		if killed:
			if tower_type != 1:
				target = null

func fire_at_all_targets():
	var valid_targets = []
	
	for t in targets:
		if weakref(t).get_ref():
			valid_targets.append(t)
	
	targets = valid_targets
	
	if targets.size() > 0 and can_fire:
		var effect_scene = load("res://scenes/tower_area_effect.tscn")
		var effect = effect_scene.instantiate()
		effect.set_range(tower_range)
		add_child(effect)
		
		var tween = create_tween()
		tween.tween_property(effect, "modulate", Color(1, 1, 1, 0), 0.3)
		tween.tween_callback(func(): effect.queue_free())
		
		if has_node("PopSound"):
			$PopSound.play()
		
		for t in targets:
			if t.has_method("take_damage"):
				t.take_damage(tower_damage)

func upgrade():
	if tower_level >= max_level:
		return -1  
		
	tower_level += 1
	
	match tower_type:
		0:
			tower_damage += 5
			tower_fire_rate *= 0.9
		1:
			tower_damage += 2
			tower_range += 25
		2:
			tower_damage += 15
		3:
			slow_factor -= 0.1
			slow_duration += 0.5
	
	if has_node("FireRateTimer"):
		$FireRateTimer.wait_time = tower_fire_rate
	
	if has_node("Node2D/Area2D/CollisionShape2D"):
		$Node2D/Area2D/CollisionShape2D.shape.radius = tower_range
	
	if has_node("RangeIndicator"):
		$RangeIndicator.set_range(tower_range)
	
	return tower_cost * tower_level

func can_upgrade() -> bool:
	return tower_level < max_level

func get_max_level() -> int:
	return max_level

func show_range(display_range = true):
	if has_node("RangeIndicator"):
		$RangeIndicator.queue_free()
	
	if display_range:
		var range_indicator_scene = load("res://scenes/range_indicator.tscn")
		var indicator = range_indicator_scene.instantiate()
		indicator.name = "RangeIndicator"
		indicator.set_range(tower_range)
		add_child(indicator)
