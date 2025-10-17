extends BaseTower
class_name SniperTower

func _init():
	tower_name = "Sniper Tower"
	tower_cost = 300
	tower_range = 500.0
	tower_damage = 30
	tower_fire_rate = 2.0
	
	projectile_scene = preload("res://scenes/sniper_projectile.tscn")

func _ready():
	if has_node("Basic-tower-top"):
		var texture = load("res://assets/kenney_top-down-tanks-redux/PNG/Default size/tank_green.png")
		if texture:
			$"Basic-tower-top".texture = texture
	
	super._ready()

func apply_upgrade_effects():
	tower_damage += 15
