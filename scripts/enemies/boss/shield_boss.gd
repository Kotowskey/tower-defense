extends BaseBossEnemy
class_name ShieldBoss

func _ready():
	boss_type = 2
	enemy_type = 0
	max_health = 350
	speed = 120
	value = 250
	scale = Vector2(1.4, 1.4)
	
	$CharacterBody2D/Sprite2D.modulate = Color(0.2, 0.2, 0.8)
	
	super._ready()

func take_damage(damage):
	return super.take_damage(int(damage * 0.7))
