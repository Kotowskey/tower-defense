extends BaseEnemy
class_name TankEnemy

func _init():
	enemy_type = 2
	max_health = 50
	speed = 200
	value = 45

func _ready():
	if has_node("CharacterBody2D/Sprite2D"):
		$CharacterBody2D/Sprite2D.texture = load("res://assets/kenney_pixel-vehicle-pack/PNG/Cars/truckcabin_vintage.png")
	
	super._ready()
