extends BaseTower
class_name SniperTower

func _ready():
	tower_name = "Sniper Tower"
	tower_cost = 300
	tower_range = 500.0
	tower_damage = 30
	tower_fire_rate = 2.0
	
	# Set sniper tower appearance
	if has_node("Basic-tower-top"):
		var texture = load("res://assets/kenney_top-down-tanks-redux/PNG/Default size/tank_green.png")
		if texture:
			$"Basic-tower-top".texture = texture
	
	super._ready()

func apply_upgrade_effects():
	tower_damage += 15

func get_fire_color() -> Color:
	return Color(0, 0, 1)  # Blue
