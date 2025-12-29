extends Node2D
class_name BaseEnemy

signal enemy_died(enemy_type)
signal enemy_escaped

@export var path: Path2D
@export var path_follow: PathFollow2D
@export var speed: float = 50
@export var max_health: int = 100
@export var value: int = 25

@export_category("Movement Animation")
@export var enable_movement_animation: bool = true
@export var animate_only_when_moving: bool = true
@export var bob_amplitude_px: float = 0.6
@export var bob_frequency_hz: float = 6.0
@export var squash_amount: float = 0.015
@export var tilt_degrees: float = 2.0
@export var rotate_sprite_to_movement_direction: bool = true
@export var rotation_lerp_speed: float = 12.0

var current_health: int
var current_speed: float
var slow_factor: float = 1.0
var slow_timer: Timer = null
var health_bar: ProgressBar
var enemy_type: int = 0 

var _sprite: Sprite2D
var _sprite_base_pos: Vector2
var _sprite_base_scale: Vector2
var _sprite_base_rot: float

var _anim_time: float = 0.0
var _prev_global_position: Vector2
var _has_prev_position: bool = false

func _ready():
	add_to_group("enemies")
	current_health = max_health
	current_speed = speed
	_cache_visual_nodes()
	
	setup_slow_timer()
	setup_health_bar()
	_prev_global_position = global_position
	_has_prev_position = true

func _cache_visual_nodes():
	_sprite = null
	if has_node("CharacterBody2D/Sprite2D"):
		_sprite = $CharacterBody2D/Sprite2D
		_sprite_base_pos = _sprite.position
		_sprite_base_scale = _sprite.scale
		_sprite_base_rot = _sprite.rotation

func setup_slow_timer():
	slow_timer = Timer.new()
	slow_timer.one_shot = true
	add_child(slow_timer)
	slow_timer.connect("timeout", Callable(self, "_on_slow_timer_timeout"))

func setup_health_bar():
	health_bar = $HealthBar
	if health_bar:
		health_bar.max_value = max_health
		health_bar.value = current_health
		health_bar.show()

func _process(delta):
	move_along_path(delta)
	_update_movement_animation(delta)

func _update_movement_animation(delta: float) -> void:
	if not enable_movement_animation:
		return
	if _sprite == null:
		return
	if delta <= 0.0:
		return

	# Determine movement based on actual displacement (works even if movement is path-follow based).
	if not _has_prev_position:
		_prev_global_position = global_position
		_has_prev_position = true
		return

	var displacement: Vector2 = global_position - _prev_global_position
	_prev_global_position = global_position

	var moving := displacement.length() > 0.01
	if animate_only_when_moving and not moving:
		var t := 1.0 - exp(-12.0 * delta)
		_sprite.position = _sprite.position.lerp(_sprite_base_pos, t)
		_sprite.scale = _sprite.scale.lerp(_sprite_base_scale, t)
		if not rotate_sprite_to_movement_direction:
			_sprite.rotation = lerp_angle(_sprite.rotation, _sprite_base_rot, t)
		return

	_anim_time += delta
	var phase := _anim_time * bob_frequency_hz * TAU
	var s := sin(phase)

	var y_offset := s * bob_amplitude_px
	_sprite.position = _sprite_base_pos + Vector2(0.0, y_offset)

	var sx := 1.0 + squash_amount * s
	var sy := 1.0 - squash_amount * s
	_sprite.scale = Vector2(_sprite_base_scale.x * sx, _sprite_base_scale.y * sy)

	var tilt := deg_to_rad(tilt_degrees) * s
	if rotate_sprite_to_movement_direction and moving:
		var desired := displacement.angle() + tilt
		var rt := 1.0 - exp(-rotation_lerp_speed * delta)
		_sprite.rotation = lerp_angle(_sprite.rotation, desired, rt)
	else:
		_sprite.rotation = _sprite_base_rot + tilt

func move_along_path(delta):
	if path_follow:
		path_follow.progress += current_speed * delta
		position = path_follow.global_position
		
		if path_follow.progress_ratio >= 0.99:
			emit_signal("enemy_escaped")
			queue_free()

func take_damage(damage):
	current_health -= damage
	
	if health_bar:
		health_bar.value = current_health
	
	if current_health <= 0:
		emit_signal("enemy_died", enemy_type)
		queue_free()
		return true
	return false

func apply_slow(factor, duration):
	slow_factor = min(slow_factor, factor)
	current_speed = speed * slow_factor
	
	slow_timer.wait_time = duration
	slow_timer.start()
	
	$CharacterBody2D/Sprite2D.modulate = Color(0.5, 0.5, 1)
	
	if health_bar:
		health_bar.modulate = Color(0.8, 0.8, 1.2)

func _on_slow_timer_timeout():
	slow_factor = 1.0
	current_speed = speed
	$CharacterBody2D/Sprite2D.modulate = Color(1, 1, 1)
	
	if health_bar:
		health_bar.modulate = Color(1, 1, 1)

func is_slowed() -> bool:
	return slow_factor < 1.0

func get_enemy_stats() -> Dictionary:
	return {
		"max_health": max_health,
		"current_health": current_health,
		"speed": speed,
		"value": value,
		"type": enemy_type
	}
