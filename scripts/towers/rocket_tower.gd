extends BaseTower
class_name RocketTower

var targets = []

func _init():
	tower_name = "Rocket Tower"
	tower_cost = 200
	tower_range = 250.0
	tower_damage = 5
	tower_fire_rate = 1.5

func _ready():
	if has_node("Basic-tower-top"):
		var texture = load("res://assets/kenney_top-down-tanks-redux/PNG/Default size/tank_red.png") 
		if texture:
			$"Basic-tower-top".texture = texture
	
	super._ready()
	
	if has_node("Node2D/Area2D"):
		var area = $Node2D/Area2D
		area.disconnect("body_entered", Callable(self, "_on_detection_area_body_entered"))
		area.disconnect("body_exited", Callable(self, "_on_detection_area_body_exited"))
		area.connect("body_entered", Callable(self, "_on_detection_area_body_entered_area"))
		area.connect("body_exited", Callable(self, "_on_detection_area_body_exited_area"))

func _process(_delta):
	pass

func _on_detection_area_body_entered_area(body):
	var parent = body.get_parent()
	if parent.has_method("take_damage") and not targets.has(parent):
		targets.append(parent)

func _on_detection_area_body_exited_area(body):
	var parent = body.get_parent()
	if targets.has(parent):
		targets.erase(parent)

func _on_fire_rate_timer_timeout():
	fire_at_all_targets()

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
		
		play_fire_sound()
		
		for t in targets:
			if t.has_method("take_damage"):
				t.take_damage(tower_damage)
				emit_signal("tower_fired", t)

func apply_upgrade_effects():
	tower_damage += 2
	tower_range += 25

func get_fire_color() -> Color:
	return Color(1, 0.5, 0) 