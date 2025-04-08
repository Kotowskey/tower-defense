extends Node2D

var range_value = 100.0

func set_range(value):
	range_value = value
	queue_redraw()

func _draw():
	draw_circle(Vector2.ZERO, range_value, Color(0.5, 0.5, 1.0, 0.2))
	draw_arc(Vector2.ZERO, range_value, 0, 2*PI, 32, Color(0.5, 0.5, 1.0, 0.5), 2.0)