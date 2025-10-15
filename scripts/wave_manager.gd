extends Node

signal wave_started
signal wave_completed
signal enemy_spawned
signal enemy_died
signal enemy_escaped

var game_scene
var game_state
var enemy_scene: PackedScene
var boss_enemy_scene: PackedScene
var map_node

var wave_in_progress: bool = false
var enemies_spawned: int = 0
var enemies_to_kill: int = 0
var wave_size: int = 5
var wave_delay: float = 1.0

func _init(p_game_scene, p_enemy_scene: PackedScene, p_boss_enemy_scene: PackedScene, p_game_state, p_wave_size: int, p_wave_delay: float):
	game_scene = p_game_scene
	enemy_scene = p_enemy_scene
	boss_enemy_scene = p_boss_enemy_scene
	game_state = p_game_state
	wave_size = p_wave_size
	wave_delay = p_wave_delay
	
func setup_map(p_map_node):
	map_node = p_map_node

func _on_wave_timer_timeout():
	var enemies_remaining = game_scene.get_tree().get_nodes_in_group("enemies").size()
	
	if enemies_remaining == 0 and enemies_spawned >= enemies_to_kill:
		end_wave()
		if game_scene.has_node("WaveTimer"):
			game_scene.get_node("WaveTimer").queue_free()

func start_wave():
	if wave_in_progress:
		print("Wave already in progress")
		return false
		
	wave_in_progress = true
	enemies_spawned = 0
	
	var current_wave = game_state.get_current_wave()
	var is_boss_wave = (current_wave % 5 == 0)
	
	if is_boss_wave:
		enemies_to_kill = 1 + (current_wave / 10)
	else:
		enemies_to_kill = wave_size + (current_wave * 2)
	
	var wave_timer = Timer.new()
	wave_timer.wait_time = 1.0
	wave_timer.autostart = true
	wave_timer.name = "WaveTimer"
	game_scene.add_child(wave_timer)
	wave_timer.connect("timeout", Callable(self, "_on_wave_timer_timeout"))
	
	var enemy_health_multiplier = 1.0 + (current_wave * 0.2)
	var enemy_speed_multiplier = 1.0 + (current_wave * 0.05)
	var spawn_delay = wave_delay * (1.0 - (current_wave * 0.02))
	spawn_delay = max(0.2, spawn_delay)
	
	if is_boss_wave:
		spawn_boss_wave(enemies_to_kill, enemy_health_multiplier, enemy_speed_multiplier)
	else:
		spawn_wave(enemies_to_kill, spawn_delay, enemy_health_multiplier, enemy_speed_multiplier)
	
	emit_signal("wave_started")
	return true

func end_wave():
	wave_in_progress = false
	
	var wave_reward = game_state.get_wave_reward()
	game_state.add_money(wave_reward)
	
	var wave_completed_scene = load("res://scenes/wave_completed.tscn")
	var wave_completed = wave_completed_scene.instantiate()
	wave_completed.set_wave_info(game_state.get_current_wave(), wave_reward)
	game_scene.get_node("UI/HUD").add_child(wave_completed)
	
	emit_signal("wave_completed")

func spawn_wave(num_enemies = wave_size, delay = wave_delay, health_mult = 1.0, speed_mult = 1.0):
	for i in range(num_enemies):
		var timer = game_scene.get_tree().create_timer(i * delay)
		var enemy_type = randi() % 5
		
		if i % 4 == 3:
			enemy_type = 2 + randi() % 3
		
		timer.timeout.connect(func(): 
			spawn_enemy(health_mult, speed_mult, enemy_type)
			enemies_spawned += 1
		)

func spawn_enemy(health_mult = 1.0, speed_mult = 1.0, enemy_type = 0):
	var enemy = enemy_scene.instantiate()
	var path = map_node.get_enemy_path()
	
	var path_follow = PathFollow2D.new()
	path.add_child(path_follow)
	
	enemy.path = path
	enemy.path_follow = path_follow
	enemy.enemy_type = enemy_type
	
	# Apply properties after setting enemy type
	enemy.max_health = round(enemy.max_health * health_mult)
	enemy.speed = enemy.speed * speed_mult
	
	enemy.connect("enemy_died", Callable(self, "_on_enemy_died"))
	enemy.connect("enemy_escaped", Callable(self, "_on_enemy_escaped"))
	
	enemy.add_to_group("enemies")
	
	game_scene.add_child(enemy)
	emit_signal("enemy_spawned")

func spawn_boss_wave(num_bosses = 1, health_mult = 1.0, speed_mult = 1.0):
	for i in range(num_bosses):
		var timer = game_scene.get_tree().create_timer(i * 3.0)
		timer.timeout.connect(func(): 
			spawn_boss_enemy(health_mult, speed_mult, i % 3)
			enemies_spawned += 1
		)

func spawn_boss_enemy(health_mult = 1.0, speed_mult = 1.0, boss_type = 0):
	var boss = boss_enemy_scene.instantiate()
	var path = map_node.get_enemy_path()
	
	var path_follow = PathFollow2D.new()
	path.add_child(path_follow)
	
	boss.path = path
	boss.path_follow = path_follow
	boss.boss_type = boss_type
	
	boss.max_health = round(boss.max_health * health_mult)
	boss.speed = boss.speed * speed_mult
	
	boss.connect("enemy_died", Callable(self, "_on_boss_died"))
	boss.connect("enemy_escaped", Callable(self, "_on_enemy_escaped"))
	
	boss.add_to_group("enemies")
	
	game_scene.add_child(boss)
	emit_signal("enemy_spawned")

func _on_enemy_died(enemy_type = 0):
	game_state.add_money(game_state.get_enemy_reward(enemy_type))
	emit_signal("enemy_died")

func _on_boss_died():
	var boss_reward = game_state.enemy_reward * 8
	game_state.add_money(boss_reward)
	emit_signal("enemy_died")

func _on_enemy_escaped():
	game_state.reduce_lives(1)
	emit_signal("enemy_escaped")

func is_wave_in_progress():
	return wave_in_progress
