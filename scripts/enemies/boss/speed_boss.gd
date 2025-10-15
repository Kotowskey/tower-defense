extends BaseBossEnemy
class_name SpeedBoss

func _ready():
	boss_type = 1
	enemy_type = 0
	max_health = 200
	speed = 300
	value = 150
	scale = Vector2(1.2, 1.2)
	
	$CharacterBody2D/Sprite2D.modulate = Color(0.2, 0.8, 0.2)
	
	super._ready()
