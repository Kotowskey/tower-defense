extends BaseTower
class_name BasicTower

func _init():
	tower_name = "Basic Tower"
	tower_cost = 100
	tower_range = 300.0
	tower_damage = 10
	tower_fire_rate = 1.0

func _ready():
	super._ready()

func apply_upgrade_effects():
	tower_damage += 5
	tower_fire_rate *= 0.9
