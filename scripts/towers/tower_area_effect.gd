extends Node2D

var range_value = 100.0

func set_range(value):
	range_value = value
	queue_redraw()

func _draw():
	draw_circle(Vector2.ZERO, range_value, Color(1, 0.5, 0, 0.3))
