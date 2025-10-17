extends BaseTower
class_name IceTower

var slow_factor: float = 0.5
var slow_duration: float = 2.0

func _init():
	tower_name = "Ice Tower"
	tower_cost = 150
	tower_range = 250.0
	tower_damage = 5
	tower_fire_rate = 1.0
	slow_factor = 0.5
	slow_duration = 2.0
	
	projectile_scene = preload("res://scenes/ice_projectile.tscn")

func _ready():
	if has_node("Basic-tower-top"):
		var texture = load("res://assets/kenney_top-down-tanks-redux/PNG/Default size/tank_blue.png")
		if texture:
			$"Basic-tower-top".texture = texture
	
	super._ready()

func _on_detection_area_body_entered(body):
	var parent = body.get_parent()
	if parent.has_method("take_damage") and not target:
		if not parent.has_method("is_slowed") or not parent.is_slowed():
			target = parent

func find_new_target():
	if detection_area:
		var bodies = detection_area.get_overlapping_bodies()
		for b in bodies:
			var p = b.get_parent()
			if p.has_method("take_damage"):
				if p.has_method("is_slowed") and p.is_slowed():
					continue
				target = p
				break

func _on_fire_rate_timer_timeout():
	if target and weakref(target).get_ref():
		if target.has_method("is_slowed") and target.is_slowed():
			return
	
	super._on_fire_rate_timer_timeout()

func spawn_projectile(enemy_target):
	if not projectile_scene:
		return
	
	var projectile = projectile_scene.instantiate()
	get_parent().add_child(projectile)
	projectile.setup(global_position, enemy_target, tower_damage)
	
	if projectile.has_method("set_slow_properties"):
		projectile.set_slow_properties(slow_factor, slow_duration)

func apply_upgrade_effects():
	slow_factor -= 0.1
	slow_duration += 0.5
	tower_damage += 2

func get_tower_stats() -> Dictionary:
	var stats = super.get_tower_stats()
	stats["slow_factor"] = slow_factor
	stats["slow_duration"] = slow_duration
	return stats
