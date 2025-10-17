extends BaseProjectile
class_name BasicProjectile

func _ready():
	super._ready()
	speed = 1500.0
	
	var sprite = Sprite2D.new()
	add_child(sprite)
	
	var image = Image.create(8, 8, false, Image.FORMAT_RGBA8)
	image.fill(Color.RED)
	var texture = ImageTexture.create_from_image(image)
	sprite.texture = texture
	sprite.scale = Vector2(0.5, 0.5)

func setup(start_pos: Vector2, target_enemy, projectile_damage: int):
	super.setup(start_pos, target_enemy, projectile_damage)
