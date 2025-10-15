extends BaseEnemy
class_name FastEnemy

func _ready():
	enemy_type = 1
	max_health = 15
	speed = 600.0
	value = 35
	
	if has_node("CharacterBody2D/Sprite2D"):
		$CharacterBody2D/Sprite2D.texture = load("res://assets/kenney_pixel-vehicle-pack/PNG/Cars/sports_red.png")
	
	super._ready()
