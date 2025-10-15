extends BaseBossEnemy
class_name TankBoss

func _ready():
	boss_type = 0
	enemy_type = 0  # For compatibility with reward system
	max_health = 500
	speed = 80
	value = 200
	
	$CharacterBody2D/Sprite2D.modulate = Color(0.8, 0.2, 0.2)
	
	super._ready()
