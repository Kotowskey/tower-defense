extends BaseTower
class_name MagicTower

func _init():
	tower_name = "Magic Tower"
	tower_cost = 250
	tower_range = 350.0
	tower_damage = 20
	tower_fire_rate = 1.5  # Slower but powerful

func _ready():
	if has_node("Basic-tower-top"):
		var texture = load("res://assets/kenney_top-down-tanks-redux/PNG/Default size/tank_huge.png")
		if texture:
			$"Basic-tower-top".texture = texture
	
	super._ready()
	projectile_scene = preload("res://scenes/rocket_projectile.tscn")  # Use rocket projectile for magic effect

func get_tower_type() -> String:
	return "magic"

func apply_upgrade_effects():
	tower_damage += 10
	tower_fire_rate *= 0.88
	tower_range += 20.0

func get_tower_description() -> String:
	return "Powerful magical attacks with long range. Expensive but devastating."
