extends Node2D
class_name BaseTower

signal tower_fired(target)
signal tower_upgraded

@export var tower_level: int = 1 
@export var max_level: int = 5

@export var tower_cost: int = 100
@export var tower_range: float = 300.0
@export var tower_damage: int = 10
@export var tower_fire_rate: float = 1.0
@export var tower_name: String = "Tower"

var can_fire: bool = true
var target = null
var detection_area = null
var range_indicator = null

func _ready():
	setup_detection_area()
	setup_fire_rate_timer()

func setup_detection_area():
	if not has_node("Node2D"):
		var detection_scene = load("res://scenes/detection_area.tscn")
		var area_node = detection_scene.instantiate()
		add_child(area_node)
		
		var area = area_node.get_node("Area2D")
		var shape = area.get_node("CollisionShape2D").shape
		shape.radius = tower_range
		
		area.connect("body_entered", Callable(self, "_on_detection_area_body_entered"))
		area.connect("body_exited", Callable(self, "_on_detection_area_body_exited"))
	
	detection_area = $Node2D/Area2D

func setup_fire_rate_timer():
	var timer = Timer.new()
	timer.name = "FireRateTimer"
	timer.wait_time = tower_fire_rate
	timer.one_shot = false
	add_child(timer)
	timer.connect("timeout", Callable(self, "_on_fire_rate_timer_timeout"))
	
	await get_tree().process_frame
	timer.start()

func _process(_delta):
	track_target()

func track_target():
	if target and weakref(target).get_ref():
		var direction = target.global_position - global_position
		if has_node("Basic-tower-top"):
			$"Basic-tower-top".rotation = direction.angle() + PI/2 + PI

func _on_detection_area_body_entered(body):
	var parent = body.get_parent()
	if parent.has_method("take_damage") and not target:
		target = parent

func _on_detection_area_body_exited(body):
	var parent = body.get_parent()
	if target == parent:
		target = null
		find_new_target()

func find_new_target():
	if detection_area:
		var bodies = detection_area.get_overlapping_bodies()
		for b in bodies:
			var p = b.get_parent()
			if p.has_method("take_damage"):
				target = p
				break

func _on_fire_rate_timer_timeout():
	if target and weakref(target).get_ref() and can_fire:
		fire_at_target(target)

func fire_at_target(enemy_target):
	if enemy_target.has_method("take_damage"):
		create_fire_effect(enemy_target)
		play_fire_sound()
		
		var killed = enemy_target.take_damage(tower_damage)
		
		if killed:
			target = null
			find_new_target()
		
		emit_signal("tower_fired", enemy_target)

func create_fire_effect(enemy_target):
	var line = Line2D.new()
	line.width = 2
	line.default_color = get_fire_color()
	line.add_point(Vector2.ZERO)
	line.add_point(enemy_target.global_position - global_position)
	add_child(line)
	
	var tween = create_tween()
	tween.tween_property(line, "modulate", Color(1, 1, 1, 0), 0.2)
	tween.tween_callback(func(): line.queue_free())

func play_fire_sound():
	if has_node("PopSound"):
		$PopSound.play()

func get_fire_color() -> Color:
	return Color(1, 0, 0)  # Default red color

func upgrade() -> int:
	if tower_level >= max_level:
		return -1
		
	tower_level += 1
	apply_upgrade_effects()
	
	if has_node("FireRateTimer"):
		$FireRateTimer.wait_time = tower_fire_rate
	
	if has_node("Node2D/Area2D/CollisionShape2D"):
		$Node2D/Area2D/CollisionShape2D.shape.radius = tower_range
	
	update_range_indicator()
	
	emit_signal("tower_upgraded")
	return get_upgrade_cost()

func apply_upgrade_effects():
	# To be overridden by child classes
	tower_damage += 5

func can_upgrade() -> bool:
	return tower_level < max_level

func get_max_level() -> int:
	return max_level

func get_upgrade_cost() -> int:
	return tower_cost * tower_level

func show_range(display_range = true):
	if range_indicator:
		range_indicator.queue_free()
		range_indicator = null
	
	if display_range:
		var range_indicator_scene = load("res://scenes/range_indicator.tscn")
		var indicator = range_indicator_scene.instantiate()
		indicator.name = "RangeIndicator"
		indicator.set_range(tower_range)
		add_child(indicator)
		range_indicator = indicator

func update_range_indicator():
	if range_indicator:
		range_indicator.set_range(tower_range)

func get_tower_stats() -> Dictionary:
	return {
		"name": tower_name,
		"level": tower_level,
		"max_level": max_level,
		"damage": tower_damage,
		"range": tower_range,
		"fire_rate": tower_fire_rate,
		"cost": tower_cost
	}
