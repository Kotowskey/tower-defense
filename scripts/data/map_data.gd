class_name MapData
extends Resource


@export var map_name: String = ""
@export var map_description: String = ""
@export var map_path: String = ""
@export var preview_image_path: String = ""
@export var difficulty_rating: int = 1  # 1-5 gwiazdek
@export var is_locked: bool = false

func _init(
	p_name: String = "",
	p_description: String = "",
	p_path: String = "",
	p_preview: String = "",
	p_difficulty: int = 1,
	p_locked: bool = false
):
	map_name = p_name
	map_description = p_description
	map_path = p_path
	preview_image_path = p_preview
	difficulty_rating = p_difficulty
	is_locked = p_locked

func get_display_name() -> String:
	return map_name if map_name != "" else "Unnamed Map"

func get_description() -> String:
	return map_description if map_description != "" else "No description available"

func get_difficulty_stars() -> String:
	var stars = ""
	for i in range(5):
		if i < difficulty_rating:
			stars += "★"
		else:
			stars += "☆"
	return stars

func is_available() -> bool:
	return not is_locked
