extends BaseEnemy
class_name BasicEnemy

func _init():
	enemy_type = 0
	max_health = 25
	speed = 300
	value = 25

func _ready():
	if has_node("CharacterBody2D/Sprite2D"):
		$CharacterBody2D/Sprite2D.texture = load("res://assets/kenney_pixel-vehicle-pack/PNG/Cars/rounded_red.png")
	
	super._ready()
