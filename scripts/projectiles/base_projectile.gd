extends Area2D
class_name BaseProjectile

var speed: float = 400.0
var damage: int = 10
var target = null
var direction: Vector2 = Vector2.ZERO

var has_area_damage: bool = false
var area_damage_radius: float = 0.0

func _ready():
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)

func _physics_process(delta):
	if target and weakref(target).get_ref():
		var distance_to_target = global_position.distance_to(target.global_position)
		if distance_to_target < 20.0:  
			on_hit()
			return
		
		direction = (target.global_position - global_position).normalized()
		rotation = direction.angle() + PI/2
	
	global_position += direction * speed * delta
	
	if global_position.length() > 3000:
		queue_free()

func setup(start_pos: Vector2, target_enemy, projectile_damage: int):
	global_position = start_pos
	target = target_enemy
	damage = projectile_damage
	
	if target and weakref(target).get_ref():
		direction = (target.global_position - global_position).normalized()
		rotation = direction.angle() + PI/2

func _on_body_entered(body):
	var parent = body.get_parent()
	if parent and parent.has_method("take_damage"):
		on_hit()

func _on_area_entered(area):
	var parent = area.get_parent()
	if parent and parent.has_method("take_damage"):
		on_hit()

func on_hit():
	if has_area_damage and area_damage_radius > 0:
		deal_area_damage()
	else:
		if target and weakref(target).get_ref() and target.has_method("take_damage"):
			target.take_damage(damage)
	queue_free()

func deal_area_damage():
	var damaged_enemies = []
	var all_enemies = get_tree().get_nodes_in_group("enemies")
	
	for enemy in all_enemies:
		if enemy and is_instance_valid(enemy):
			var distance = global_position.distance_to(enemy.global_position)
			if distance <= area_damage_radius:
				if enemy.has_method("take_damage") and enemy not in damaged_enemies:
					enemy.take_damage(damage)
					damaged_enemies.append(enemy)
	
	create_explosion_effect()

func create_explosion_effect():
	var explosion = Node2D.new()
	get_parent().add_child(explosion)
	explosion.global_position = global_position
	
	var sprite = Sprite2D.new()
	explosion.add_child(sprite)
	
	var scale_factor = area_damage_radius / 1000
	sprite.scale = Vector2(scale_factor, scale_factor)
	sprite.modulate = Color(1.0, 0.7, 0.3)
	
	var explosion_frames = []
	for i in range(9):
		var texture = load("res://assets/kenney_smoke-particles/PNG/Explosion/explosion0%d.png" % i)
		if texture:
			explosion_frames.append(texture)
	
	var frame_data = [0] 
	var anim_timer = Timer.new()
	explosion.add_child(anim_timer)
	anim_timer.wait_time = 0.05
	anim_timer.one_shot = false
	anim_timer.timeout.connect(func():
		if frame_data[0] < explosion_frames.size():
			sprite.texture = explosion_frames[frame_data[0]]
			frame_data[0] += 1
		else:
			anim_timer.queue_free()
	)
	anim_timer.start()
	
	var flash = Sprite2D.new()
	explosion.add_child(flash)
	var flash_texture = load("res://assets/kenney_smoke-particles/PNG/Flash/flash00.png")
	if flash_texture:
		flash.texture = flash_texture
		flash.scale = Vector2(scale_factor * 0.5, scale_factor * 0.5)
		flash.modulate = Color(1, 0.8, 0.4, 0.8)
		
		var tween = explosion.create_tween()
		tween.tween_property(flash, "modulate:a", 0.0, 0.15)
		tween.tween_callback(func(): flash.queue_free())
	
	var cleanup_timer = Timer.new()
	explosion.add_child(cleanup_timer)
	cleanup_timer.wait_time = 0.1  
	cleanup_timer.one_shot = true
	cleanup_timer.timeout.connect(func(): explosion.queue_free())
	cleanup_timer.start()
