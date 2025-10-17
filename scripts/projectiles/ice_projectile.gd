extends BaseProjectile
class_name IceProjectile

var slow_factor: float = 0.5
var slow_duration: float = 2.0

func _ready():
	super._ready()
	speed = 1500.0
	
	var sprite = Sprite2D.new()
	add_child(sprite)
	
	var image = Image.create(8, 8, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 1, 1))  
	var texture = ImageTexture.create_from_image(image)
	sprite.texture = texture
	sprite.scale = Vector2(0.5, 0.5)

func set_slow_properties(factor: float, duration: float):
	slow_factor = factor
	slow_duration = duration

func on_hit():
	if target and weakref(target).get_ref() and target.has_method("take_damage"):
		target.take_damage(damage)
		
		if target.has_method("apply_slow"):
			target.apply_slow(slow_factor, slow_duration)
	
	queue_free()
