extends BaseProjectile
class_name SniperProjectile

func _ready():
	super._ready()
	speed = 700.0  
	
	var sprite = Sprite2D.new()
	add_child(sprite)
	
	var image = Image.create(8, 8, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 1)) 
	var texture = ImageTexture.create_from_image(image)
	sprite.texture = texture
	sprite.scale = Vector2(0.6, 0.6)  
