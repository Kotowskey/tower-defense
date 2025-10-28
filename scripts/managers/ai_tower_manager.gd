extends Node

var game_scene
var tower_manager
var game_state
var map_node

var ai_money: int = 300
var ai_lives: int = 10
var tower_placement_cooldown: float = 2.0
var current_cooldown: float = 0.0
var max_towers: int = 12

var strategic_positions = []
var placed_towers = []

func _init(p_game_scene, p_tower_manager, p_game_state):
	game_scene = p_game_scene
	tower_manager = p_tower_manager
	game_state = p_game_state

func setup_map(p_map_node):
	map_node = p_map_node
	call_deferred("_calculate_strategic_positions")
	set_process(true)

func _process(delta):
	current_cooldown -= delta
	
	if current_cooldown <= 0 and placed_towers.size() < max_towers:
		_try_place_tower()
		current_cooldown = tower_placement_cooldown

func _calculate_strategic_positions():
	if not map_node:
		print("AI: No map node!")
		return
	
	if not map_node.has_method("get_path_points"):
		print("AI: Map doesn't have get_path_points method!")
		return
	
	var path_points = map_node.get_path_points()
	print("AI: Found ", path_points.size(), " path points")
	
	if path_points.size() < 2:
		print("AI: Not enough path points!")
		return
	
	var points_count = path_points.size()
	var interval = max(1, points_count / 6)
	
	for i in range(0, points_count, interval):
		if i >= points_count:
			break
		
		var path_point = path_points[i]
		var offset_distance = 100.0
		
		for angle in [PI/2, -PI/2, PI/4, -PI/4, 3*PI/4, -3*PI/4]:
			var offset = Vector2(cos(angle), sin(angle)) * offset_distance
			var potential_pos = path_point + offset
			
			if _is_valid_strategic_position(potential_pos):
				strategic_positions.append(potential_pos)
				print("AI: Added strategic position at ", potential_pos)
				break
	
	print("AI: Total strategic positions: ", strategic_positions.size())

func _is_valid_strategic_position(pos: Vector2) -> bool:
	if map_node and map_node.has_method("is_position_on_path"):
		if map_node.is_position_on_path(pos):
			return false
	
	for other_pos in strategic_positions:
		if pos.distance_to(other_pos) < 80.0:
			return false
	
	return true

func _try_place_tower():
	if strategic_positions.is_empty():
		print("AI: No strategic positions available!")
		return
	
	var tower_type = _choose_tower_type()
	var tower_cost = tower_manager.tower_costs[tower_type]
	
	print("AI: Trying to place tower type ", tower_type, " (cost: ", tower_cost, ", money: ", ai_money, ")")
	
	if ai_money < tower_cost:
		print("AI: Not enough money!")
		return
	
	var best_position = _find_best_position(tower_type)
	if best_position == null:
		print("AI: No valid position found!")
		return
	
	var tower = await _place_ai_tower(best_position, tower_type)
	if tower:
		ai_money -= tower_cost
		placed_towers.append(tower)
		print("AI placed tower type ", tower_type, " at ", best_position, " - Money left: ", ai_money)

func _choose_tower_type() -> int:
	var basic_count = 0
	var rocket_count = 0
	var sniper_count = 0
	var ice_count = 0
	
	for tower in placed_towers:
		if not is_instance_valid(tower):
			continue
		
		var script_path = tower.get_script().resource_path if tower.get_script() else ""
		if "basic_tower" in script_path:
			basic_count += 1
		elif "rocket_tower" in script_path:
			rocket_count += 1
		elif "sniper_tower" in script_path:
			sniper_count += 1
		elif "ice_tower" in script_path:
			ice_count += 1
	
	if placed_towers.size() < 3:
		return 0
	elif ice_count == 0 and ai_money >= 150:
		return 3
	elif rocket_count < 2 and ai_money >= 200:
		return 1
	elif sniper_count < 1 and ai_money >= 300:
		return 2
	else:
		return 0

func _find_best_position(tower_type: int):
	var best_pos = null
	var best_score = -1.0
	
	for pos in strategic_positions:
		if _is_position_occupied(pos):
			continue
		
		var score = _evaluate_position(pos, tower_type)
		if score > best_score:
			best_score = score
			best_pos = pos
	
	return best_pos

func _is_position_occupied(pos: Vector2) -> bool:
	for tower in placed_towers:
		if is_instance_valid(tower) and tower.position.distance_to(pos) < 50.0:
			return true
	return false

func _evaluate_position(pos: Vector2, tower_type: int) -> float:
	var score = 0.0
	
	if map_node and map_node.has_method("get_path_points"):
		var path_points = map_node.get_path_points()
		var min_distance = INF
		
		for point in path_points:
			var dist = pos.distance_to(point)
			if dist < min_distance:
				min_distance = dist
		
		if min_distance < 200:
			score += (200 - min_distance) / 200.0 * 10.0
	
	var isolation_score = 10.0
	for tower in placed_towers:
		if is_instance_valid(tower):
			var dist = pos.distance_to(tower.position)
			if dist < 100:
				isolation_score -= 5.0
	
	score += max(0, isolation_score)
	
	return score

func _place_ai_tower(pos: Vector2, tower_type: int):
	var tower = tower_manager.tower_scene.instantiate()
	tower.position = pos
	
	if tower_manager.tower_classes.has(tower_type):
		tower.set_script(tower_manager.tower_classes[tower_type])
	
	tower.add_to_group("towers")
	tower.add_to_group("ai_towers")
	game_scene.add_child(tower)
	
	await game_scene.get_tree().process_frame
	
	if tower.has_method("set"):
		tower.is_placed = true
	
	if tower.has_method("show_range"):
		tower.show_range(false)
	
	return tower

func add_money(amount: int):
	ai_money += amount

func lose_life():
	ai_lives -= 1
	print("AI lost a life! Lives remaining: ", ai_lives)
	
	if game_scene.has_method("_on_ai_life_lost"):
		game_scene._on_ai_life_lost()
	
	if ai_lives <= 0:
		_on_ai_defeated()

func _on_ai_defeated():
	print("AI defeated! Player wins!")
	if game_scene.has_method("_on_player_victory"):
		game_scene._on_player_victory()

func get_lives() -> int:
	return ai_lives

func get_money() -> int:
	return ai_money
