extends BaseEnemy
class_name FastEnemy

func _init():
	enemy_type = 1
	max_health = 15
	speed = 450
	value = 35

func _ready():
	if has_node("CharacterBody2D/Sprite2D"):
		$CharacterBody2D/Sprite2D.texture = load("res://assets/kenney_pixel-vehicle-pack/PNG/Cars/sports_red.png")
	
	super._ready()
