extends Node

signal enemy_spawned
signal wave_ready
signal wave_completed

var game_scene
var game_state
var map_node

var enemy_scene: PackedScene
var boss_enemy_scene: PackedScene

var player_money: int = 150
var current_wave: int = 1
var enemies_alive: int = 0
var wave_active: bool = false

var enemy_types = {
	0: {"cost": 10, "name": "Basic", "script": preload("res://scripts/enemies/basic_enemy.gd")},
	1: {"cost": 15, "name": "Fast", "script": preload("res://scripts/enemies/fast_enemy.gd")},
	2: {"cost": 25, "name": "Tank", "script": preload("res://scripts/enemies/tank_enemy.gd")}
}

var spawn_queue = []
var spawn_cooldown: float = 0.5
var current_spawn_cooldown: float = 0.0

func _init(p_game_scene, p_enemy_scene: PackedScene, p_boss_enemy_scene: PackedScene, p_game_state):
	game_scene = p_game_scene
	enemy_scene = p_enemy_scene
	boss_enemy_scene = p_boss_enemy_scene
	game_state = p_game_state

func setup_map(p_map_node):
	map_node = p_map_node
	set_process(true)
	call_deferred("start_wave")

func _process(delta):
	if current_spawn_cooldown > 0:
		current_spawn_cooldown -= delta
	
	if current_spawn_cooldown <= 0 and not spawn_queue.is_empty():
		_spawn_next_in_queue()
		current_spawn_cooldown = spawn_cooldown

func queue_enemy(enemy_type: int) -> bool:
	if not enemy_types.has(enemy_type):
		return false
	
	var cost = enemy_types[enemy_type]["cost"]
	
	if player_money < cost:
		print("Not enough money to spawn enemy!")
		return false
	
	player_money -= cost
	spawn_queue.append(enemy_type)
	
	print("Queued ", enemy_types[enemy_type]["name"], " enemy. Queue size: ", spawn_queue.size())
	return true

func _spawn_next_in_queue():
	if spawn_queue.is_empty():
		return
	
	var enemy_type = spawn_queue.pop_front()
	_spawn_enemy(enemy_type)

func _spawn_enemy(enemy_type: int):
	if not map_node:
		print("Error: Map node not set!")
		return
	
	var enemy = enemy_scene.instantiate()
	var path = map_node.get_enemy_path()
	
	var path_follow = PathFollow2D.new()
	path.add_child(path_follow)
	
	if enemy_types.has(enemy_type):
		enemy.set_script(enemy_types[enemy_type]["script"])
	
	enemy.path = path
	enemy.path_follow = path_follow
	
	enemy.add_to_group("enemies")
	enemy.add_to_group("player_enemies")
	
	enemy._ready()
	
	if enemy.has_signal("enemy_died"):
		enemy.connect("enemy_died", Callable(self, "_on_enemy_died"))
	if enemy.has_signal("enemy_escaped"):
		enemy.connect("enemy_escaped", Callable(self, "_on_enemy_reached_end"))
	
	game_scene.add_child(enemy)
	enemies_alive += 1
	
	emit_signal("enemy_spawned")
	print("Spawned enemy type ", enemy_type, ". Alive: ", enemies_alive)

func _on_enemy_died(enemy):
	enemies_alive -= 1
	print("Enemy died. Alive: ", enemies_alive, " Queue: ", spawn_queue.size())
	
	if enemies_alive <= 0 and spawn_queue.is_empty() and wave_active:
		_check_wave_completion()

func _on_enemy_reached_end(enemy):
	enemies_alive -= 1
	print("Enemy reached end! AI loses a life. Alive: ", enemies_alive, " Queue: ", spawn_queue.size())
	
	if game_scene.has_node("AITowerManager"):
		var ai_manager = game_scene.get_node("AITowerManager")
		ai_manager.lose_life()
		print("AI lives after hit: ", ai_manager.get_lives())
	else:
		print("ERROR: AITowerManager not found!")
	
	if enemies_alive <= 0 and spawn_queue.is_empty() and wave_active:
		_check_wave_completion()

func _check_wave_completion():
	wave_active = false
	
	var wave_reward = 100 + (current_wave * 15)
	player_money += wave_reward
	
	print("Wave ", current_wave, " completed! Reward: ", wave_reward)
	print("Next wave: ", current_wave + 1, " | Money: ", player_money)
	
	current_wave += 1
	
	emit_signal("wave_completed", current_wave, wave_reward)
	
	await game_scene.get_tree().create_timer(2.0).timeout
	start_wave()

func start_wave():
	if wave_active:
		print("Wave already active!")
		return false
	
	wave_active = true
	print("========================================")
	print("Wave ", current_wave, " started!")
	print("Spawn enemies to attack AI defenses!")
	print("========================================")
	return true

func can_spawn_enemy(enemy_type: int) -> bool:
	if not enemy_types.has(enemy_type):
		return false
	
	var cost = enemy_types[enemy_type]["cost"]
	return player_money >= cost

func get_enemy_cost(enemy_type: int) -> int:
	if enemy_types.has(enemy_type):
		return enemy_types[enemy_type]["cost"]
	return 0

func get_money() -> int:
	return player_money

func add_money(amount: int):
	player_money += amount

func get_current_wave() -> int:
	return current_wave

func get_queue_size() -> int:
	return spawn_queue.size()

func get_enemies_alive() -> int:
	return enemies_alive
