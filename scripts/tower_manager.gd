extends Node

signal tower_selected(tower)
signal tower_deselected

var tower_scene: PackedScene
var game_scene
var game_state
var tower_preview = null
var building_mode: bool = false
var current_tower_type = 0
var selected_tower = null
var tower_info_display = null
var minimum_tower_distance: float = 100.0
var is_valid_position: bool = true

var tower_costs = {
	0: 100, # Basic tower
	1: 200, # Area tower
	2: 300, # Sniper tower
	3: 150  # Slow tower
}

func _init(p_game_scene, p_tower_scene: PackedScene, p_game_state):
	game_scene = p_game_scene
	tower_scene = p_tower_scene
	game_state = p_game_state

func _process(_delta):
	if building_mode and tower_preview:
		var mouse_pos = game_scene.get_global_mouse_position()
		tower_preview.position = mouse_pos
		
		is_valid_position = is_valid_tower_position(mouse_pos)
		if is_valid_position:
			tower_preview.modulate = Color(1, 1, 1, 0.5)
		else:
			tower_preview.modulate = Color(1, 0.3, 0.3, 0.5)

func setup_tower_info_display(info_display):
	tower_info_display = info_display
	tower_info_display.visible = false

func start_tower_placement(tower_type):
	current_tower_type = tower_type
	building_mode = true
	deselect_tower()

	if tower_preview:
		tower_preview.queue_free()

	tower_preview = tower_scene.instantiate()
	tower_preview.tower_type = tower_type
	
	game_scene.add_child(tower_preview)
	
	await game_scene.get_tree().process_frame
	
	tower_preview.modulate = Color(1, 1, 1, 0.5)
	if tower_preview.has_method("show_range"):
		tower_preview.show_range(true)

func is_valid_tower_position(pos: Vector2) -> bool:
	for tower in game_scene.get_tree().get_nodes_in_group("towers"):
		var distance = pos.distance_to(tower.position)
		if distance < minimum_tower_distance:
			return false
	
	if game_scene.has_node("Map"):
		var map_node = game_scene.get_node("Map")
		if map_node.has_method("is_position_on_path"):
			if map_node.is_position_on_path(pos):
				return false
	
	return true

func place_tower(pos):
	var selected_tower_cost = tower_costs[current_tower_type]
	
	if !is_valid_tower_position(pos):
		return false
	
	if game_state.has_enough_money(selected_tower_cost):
		var new_tower = tower_scene.instantiate()
		new_tower.position = pos
		new_tower.tower_type = current_tower_type
		new_tower.add_to_group("towers")

		game_scene.add_child(new_tower)
		if game_scene.has_node("TowerCreation"):
			game_scene.get_node("TowerCreation").play()
		
		game_state.reduce_money(selected_tower_cost)
		cancel_building()
		return true
	else:
		print("Not enough money to place tower")
		return false

func cancel_building():
	building_mode = false
	if tower_preview:
		if tower_preview.has_method("show_range"):
			tower_preview.show_range(false)
		tower_preview.queue_free()
		tower_preview = null

func select_tower_at_position(pos):
	if game_scene.get_node("UI/HUD/BuildPanel/BuildUI").get_global_rect().has_point(pos):
		return
		
	var currently_selected = null
	if selected_tower:
		currently_selected = selected_tower.get_ref()
	
	deselect_tower()
	
	for tower in game_scene.get_tree().get_nodes_in_group("towers"):
		var tower_size = 64
		var tower_rect = Rect2(tower.position - Vector2(tower_size/2.0, tower_size/2.0), 
							  Vector2(tower_size, tower_size))
		
		if tower_rect.has_point(pos):
			if currently_selected == tower:
				return
			
			selected_tower = weakref(tower)
			tower.show_range(true)
			
			if tower_info_display:
				update_tower_info_display(tower)
				tower_info_display.visible = true
				tower_info_display.position = Vector2(pos.x - 100, pos.y - 150)
			
			emit_signal("tower_selected", tower)
			return

func deselect_tower():
	if selected_tower and selected_tower.get_ref():
		selected_tower.get_ref().show_range(false)
	selected_tower = null
	
	if tower_info_display:
		tower_info_display.visible = false
	
	emit_signal("tower_deselected")

func update_tower_info_display(tower):
	if tower_info_display:
		tower_info_display.set_tower_info(
			tower.tower_name,
			tower.tower_level,
			tower.tower_damage,
			tower.tower_range,
			tower.tower_fire_rate,
			tower.tower_type == 3,  
			tower.slow_factor if tower.tower_type == 3 else 0.0
		)

func upgrade_selected_tower():
	if selected_tower and selected_tower.get_ref():
		var tower = selected_tower.get_ref()
		var cost = tower.tower_cost * tower.tower_level
		
		if game_state.has_enough_money(cost):
			game_state.reduce_money(cost)
			var new_cost = tower.upgrade()
			
			update_tower_info_display(tower)
			
			if tower.has_node("RangeIndicator"):
				tower.get_node("RangeIndicator").set_range(tower.tower_range)
			else:
				tower.show_range(true)
				
			if game_scene.has_node("UpgradeSound"):
				game_scene.get_node("UpgradeSound").play()
				
			game_scene.get_viewport().set_input_as_handled()
			return true
		else:
			print("Not enough money to upgrade tower")
			return false
	return false

func get_selected_tower():
	if selected_tower and selected_tower.get_ref():
		return selected_tower.get_ref()
	return null

func get_upgrade_cost():
	if selected_tower and selected_tower.get_ref():
		var tower = selected_tower.get_ref()
		return tower.tower_cost * tower.tower_level
	return 0

func is_in_building_mode():
	return building_mode
