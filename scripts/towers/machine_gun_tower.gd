extends BaseTower
class_name MachineGunTower

func _init():
	tower_name = "Machine Gun Tower"
	tower_cost = 120
	tower_range = 250.0
	tower_damage = 2 
	tower_fire_rate = 0.15  

func _ready():
	if has_node("Basic-tower-top"):
		var texture = load("res://assets/kenney_top-down-tanks-redux/PNG/Default size/tank_sand.png")
		if texture:
			$"Basic-tower-top".texture = texture
	
	super._ready()

func get_tower_type() -> String:
	return "machine_gun"

func apply_upgrade_effects():
	tower_damage += 1  
	tower_fire_rate *= 0.95  
	tower_range += 15.0  

func get_tower_description() -> String:
	return "Rapid-fire tower with very low damage. Excels against swarms with high DPS over time."
