extends BaseTower
class_name MachineGunTower

func _init():
	tower_name = "Machine Gun Tower"
	tower_cost = 120
	tower_range = 250.0
	tower_damage = 5
	tower_fire_rate = 0.3  # Very fast fire rate

func _ready():
	if has_node("Basic-tower-top"):
		var texture = load("res://assets/kenney_top-down-tanks-redux/PNG/Default size/tank_sand.png")
		if texture:
			$"Basic-tower-top".texture = texture
	
	super._ready()

func get_tower_type() -> String:
	return "machine_gun"

func apply_upgrade_effects():
	tower_damage += 3
	tower_fire_rate *= 0.92  # Slightly faster
	tower_range += 10.0

func get_tower_description() -> String:
	return "Fast-firing tower with moderate damage. Great for swarms of enemies."
