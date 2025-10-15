extends BaseTower
class_name IceTower

var slow_factor: float = 0.5
var slow_duration: float = 2.0

func _ready():
	tower_name = "Ice Tower"
	tower_cost = 150
	tower_range = 250.0
	tower_damage = 5
	tower_fire_rate = 1.0
	slow_factor = 0.5
	slow_duration = 2.0
	
	# Set ice tower appearance
	if has_node("Basic-tower-top"):
		var texture = load("res://assets/kenney_top-down-tanks-redux/PNG/Default size/tank_blue.png")
		if texture:
			$"Basic-tower-top".texture = texture
	
	super._ready()

func fire_at_target(enemy_target):
	if enemy_target.has_method("take_damage"):
		create_fire_effect(enemy_target)
		play_fire_sound()
		
		var killed = enemy_target.take_damage(tower_damage)
		
		if enemy_target.has_method("apply_slow"):
			enemy_target.apply_slow(slow_factor, slow_duration)
		
		if killed:
			target = null
			find_new_target()
		
		emit_signal("tower_fired", enemy_target)

func apply_upgrade_effects():
	slow_factor -= 0.1
	slow_duration += 0.5
	tower_damage += 2

func get_fire_color() -> Color:
	return Color(0, 1, 1)  # Cyan

func get_tower_stats() -> Dictionary:
	var stats = super.get_tower_stats()
	stats["slow_factor"] = slow_factor
	stats["slow_duration"] = slow_duration
	return stats
