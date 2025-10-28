extends Node2D

@onready var path = $Path2D
var path_width: float = 70.0  

func _ready():
	pass

func get_enemy_path():
	return path

func get_path_points() -> Array:
	"""Returns array of Vector2 points along the path"""
	var points = []
	if not path or not path.curve:
		return points
	
	var curve = path.curve
	var point_count = curve.point_count
	
	for i in range(point_count):
		points.append(curve.get_point_position(i))
	
	return points
	
func is_position_on_path(pos: Vector2) -> bool:
	if not path:
		return false
		
	var curve = path.curve
	if not curve:
		return false
		
	var point_count = curve.point_count
	for i in range(point_count - 1):
		var point_a = curve.get_point_position(i)
		var point_b = curve.get_point_position(i + 1)
		
		var closest_point = Geometry2D.get_closest_point_to_segment(pos, point_a, point_b)
		var distance = pos.distance_to(closest_point)
		
		if distance < path_width:
			return true
			
	return false
