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
	print("Projectile hit! Area damage: ", has_area_damage, " Radius: ", area_damage_radius)
	if has_area_damage and area_damage_radius > 0:
		deal_area_damage()
	else:
		if target and weakref(target).get_ref() and target.has_method("take_damage"):
			target.take_damage(damage)
			print("Direct damage dealt: ", damage)
	queue_free()

func deal_area_damage():
	var damaged_enemies = []
	var all_enemies = get_tree().get_nodes_in_group("enemies")
	
	print("Dealing area damage. Enemies in game: ", all_enemies.size())
	
	for enemy in all_enemies:
		if enemy and is_instance_valid(enemy):
			var distance = global_position.distance_to(enemy.global_position)
			if distance <= area_damage_radius:
				if enemy.has_method("take_damage") and enemy not in damaged_enemies:
					enemy.take_damage(damage)
					damaged_enemies.append(enemy)
					print("Area damage dealt to enemy at distance: ", distance, " Damage: ", damage)
	
	print("Total enemies damaged: ", damaged_enemies.size())
	create_explosion_effect()

func create_explosion_effect():
	var explosion = Node2D.new()
	get_parent().add_child(explosion)
	explosion.global_position = global_position

	var circle = Line2D.new()
	circle.width = 3
	circle.default_color = Color(1, 0.5, 0, 0.8)
	explosion.add_child(circle)
	
	var segments = 32
	for i in range(segments + 1):
		var angle = (i / float(segments)) * TAU
		var point = Vector2(cos(angle), sin(angle)) * area_damage_radius
		circle.add_point(point)
	
	var tween = create_tween()
	tween.tween_property(circle, "modulate", Color(1, 0.5, 0, 0), 0.4)
	tween.tween_callback(func(): explosion.queue_free())
