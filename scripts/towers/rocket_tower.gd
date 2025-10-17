extends BaseTower
class_name RocketTower

func _init():
	tower_name = "Rocket Tower"
	tower_cost = 200
	tower_range = 250.0
	tower_damage = 30  
	tower_fire_rate = 2.0
	
	projectile_scene = preload("res://scenes/rocket_projectile.tscn")  

func _ready():
	if has_node("Basic-tower-top"):
		var texture = load("res://assets/kenney_top-down-tanks-redux/PNG/Default size/tank_red.png") 
		if texture:
			$"Basic-tower-top".texture = texture
	
	super._ready()

func _on_fire_rate_timer_timeout():
	if target and weakref(target).get_ref() and can_fire:
		fire_rocket(target)

func fire_rocket(enemy_target):
	if not enemy_target or not weakref(enemy_target).get_ref():
		return
	
	var projectile = projectile_scene.instantiate()
	get_parent().add_child(projectile)
	
	projectile.setup(global_position, enemy_target, tower_damage)
	
	play_fire_sound()
	
	emit_signal("tower_fired", enemy_target)

func apply_upgrade_effects():
	tower_damage += 10
	tower_range += 25
