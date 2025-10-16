extends Node

var game_scene
var game_state
var tower_manager
var wave_manager

var can_upgrade = false
var upgrade_cost = 0

func _init(p_game_scene, p_game_state, p_tower_manager, p_wave_manager):
	game_scene = p_game_scene
	game_state = p_game_state
	tower_manager = p_tower_manager
	wave_manager = p_wave_manager
	
	game_state.connect("money_changed", Callable(self, "update_money_ui"))
	game_state.connect("lives_changed", Callable(self, "update_lives_ui"))
	game_state.connect("wave_changed", Callable(self, "update_wave_ui"))
	game_state.connect("game_over", Callable(self, "show_game_over"))
	
	tower_manager.connect("tower_selected", Callable(self, "_on_tower_selected"))
	tower_manager.connect("tower_deselected", Callable(self, "_on_tower_deselected"))
	
	wave_manager.connect("wave_started", Callable(self, "_on_wave_started"))
	wave_manager.connect("wave_completed", Callable(self, "_on_wave_completed"))

func update_tower_costs_ui():
	var tower_buttons = {
		"TowerBasic": 0,
		"TowerArea": 1,
		"TowerSniper": 2,
		"TowerSlow": 3
	}
	
	for button_name in tower_buttons:
		var button_path = "UI/HUD/BuildPanel/BuildUI/" + button_name
		if game_scene.has_node(button_path):
			var button = game_scene.get_node(button_path)
			var tower_type = tower_buttons[button_name]
			var cost = tower_manager.get_tower_cost(tower_type)
			
			if button.has_node("Label"):
				var current_text = button.get_node("Label").text
				var lines = current_text.split("\n")
				if lines.size() > 1:
					button.get_node("Label").text = lines[0] + "\n" + str(cost)

func _process(_delta):
	if tower_manager.get_selected_tower():
		var selected_tower = tower_manager.get_selected_tower()
		can_upgrade = selected_tower.can_upgrade()
		upgrade_cost = tower_manager.get_upgrade_cost()
	else:
		can_upgrade = false
	
	update_upgrade_ui()

func connect_ui_buttons():
	if game_scene.has_node("UI/HUD/BuildPanel/BuildUI/TowerBasic"):
		game_scene.get_node("UI/HUD/BuildPanel/BuildUI/TowerBasic").connect("pressed", Callable(self, "_on_tower_basic_pressed"))
	
	if game_scene.has_node("UI/HUD/BuildPanel/BuildUI/TowerArea"):
		game_scene.get_node("UI/HUD/BuildPanel/BuildUI/TowerArea").connect("pressed", Callable(self, "_on_tower_area_pressed"))
	
	if game_scene.has_node("UI/HUD/BuildPanel/BuildUI/TowerSniper"):
		game_scene.get_node("UI/HUD/BuildPanel/BuildUI/TowerSniper").connect("pressed", Callable(self, "_on_tower_sniper_pressed"))
	
	if game_scene.has_node("UI/HUD/BuildPanel/BuildUI/TowerSlow"):
		game_scene.get_node("UI/HUD/BuildPanel/BuildUI/TowerSlow").connect("pressed", Callable(self, "_on_tower_slow_pressed"))
	
	if game_scene.has_node("UI/HUD/BuildPanel/BuildUI/Upgrade"):
		game_scene.get_node("UI/HUD/BuildPanel/BuildUI/Upgrade").connect("pressed", Callable(self, "_on_upgrade_pressed"))
	
	if game_scene.has_node("UI/HUD/BuildPanel/BuildUI/SpawnButton"):
		game_scene.get_node("UI/HUD/BuildPanel/BuildUI/SpawnButton").connect("pressed", Callable(self, "_on_spawn_button_pressed"))
	
	if game_scene.has_node("UI/HUD/BuildPanel/BuildUI/Sell"):
		game_scene.get_node("UI/HUD/BuildPanel/BuildUI/Sell").connect("pressed", Callable(self, "_on_sell_pressed"))
	
	if game_scene.has_node("UI/PauseMenu/MenuPanel/VBoxContainer/ResumeButton"):
		game_scene.get_node("UI/PauseMenu/MenuPanel/VBoxContainer/ResumeButton").connect("pressed", Callable(self, "_on_resume_pressed"))
	
	if game_scene.has_node("UI/PauseMenu/MenuPanel/VBoxContainer/MainMenuButton"):
		game_scene.get_node("UI/PauseMenu/MenuPanel/VBoxContainer/MainMenuButton").connect("pressed", Callable(game_scene, "_on_main_menu_pressed"))
	
	if game_scene.has_node("UI/PauseMenu"):
		game_scene.get_node("UI/PauseMenu").connect("talents_pressed", Callable(self, "_on_talents_pressed"))
	
	if game_scene.has_node("UI/HUD/InfoPanel/UserUI/TalentsButton"):
		game_scene.get_node("UI/HUD/InfoPanel/UserUI/TalentsButton").connect("pressed", Callable(self, "_on_talents_button_pressed"))
	
	if has_node("/root/TalentManager"):
		var talent_manager = get_node("/root/TalentManager")
		talent_manager.talent_points_changed.connect(Callable(self, "update_talent_points_ui"))

func update_money_ui(amount = null):
	if amount == null:
		amount = game_state.player_money
		
	if game_scene.has_node("UI/HUD/InfoPanel/UserUI/MoneyContainer/MoneyLabel"):
		game_scene.get_node("UI/HUD/InfoPanel/UserUI/MoneyContainer/MoneyLabel").text = "Money: " + str(amount)

func update_lives_ui(amount = null):
	if amount == null:
		amount = game_state.player_lives
		
	if game_scene.has_node("UI/HUD/InfoPanel/UserUI/LivesContainer/LivesLabel"):
		game_scene.get_node("UI/HUD/InfoPanel/UserUI/LivesContainer/LivesLabel").text = "Lives: " + str(amount)

func update_wave_ui(wave_number = null):
	if wave_number == null:
		wave_number = game_state.current_wave
		
	if game_scene.has_node("UI/HUD/InfoPanel/UserUI/WaveContainer/WaveLabel"):
		game_scene.get_node("UI/HUD/InfoPanel/UserUI/WaveContainer/WaveLabel").text = "Wave: " + str(wave_number)

func update_talent_points_ui(points = null):
	if points == null and has_node("/root/TalentManager"):
		var talent_manager = get_node("/root/TalentManager")
		points = talent_manager.talent_points
	
	if points == null:
		points = 0
	
	if game_scene.has_node("UI/HUD/InfoPanel/UserUI/TalentsContainer/TalentLabel"):
		game_scene.get_node("UI/HUD/InfoPanel/UserUI/TalentsContainer/TalentLabel").text = "Talent Points: " + str(points)

func update_upgrade_ui():
	if game_scene.has_node("UI/HUD/BuildPanel/BuildUI/Upgrade"):
		var upgrade_button = game_scene.get_node("UI/HUD/BuildPanel/BuildUI/Upgrade")
		var selected_tower = tower_manager.get_selected_tower()
		
		if selected_tower and selected_tower.tower_level >= selected_tower.max_level:
			upgrade_button.disabled = true
			upgrade_button.modulate = Color(0.3, 0.3, 0.3, 1)
			if upgrade_button.has_node("Label"):
				upgrade_button.get_node("Label").text = "MAX\nLEVEL"
		elif can_upgrade and game_state.has_enough_money(upgrade_cost):
			upgrade_button.disabled = false
			upgrade_button.modulate = Color(1, 1, 1, 1)
			if upgrade_button.has_node("Label"):
				upgrade_button.get_node("Label").text = "Upgrade\n" + str(upgrade_cost)
		else:
			upgrade_button.disabled = true
			upgrade_button.modulate = Color(0.5, 0.5, 0.5, 1)
			if upgrade_button.has_node("Label"):
				if can_upgrade:
					upgrade_button.get_node("Label").text = "Upgrade\n" + str(upgrade_cost)
				else:
					upgrade_button.get_node("Label").text = "Upgrade"
	
	if game_scene.has_node("UI/HUD/BuildPanel/BuildUI/Sell"):
		var sell_button = game_scene.get_node("UI/HUD/BuildPanel/BuildUI/Sell")
		var selected_tower = tower_manager.get_selected_tower()
		if selected_tower:
			var refund = tower_manager.get_sell_refund()
			sell_button.disabled = false
			sell_button.modulate = Color(1, 1, 1, 1)
			if sell_button.has_node("Label"):
				sell_button.get_node("Label").text = "Sell\n+" + str(refund)
		else:
			sell_button.disabled = true
			sell_button.modulate = Color(0.5, 0.5, 0.5, 1)
			if sell_button.has_node("Label"):
				sell_button.get_node("Label").text = "Sell"

func _on_tower_basic_pressed():
	tower_manager.start_tower_placement(0)

func _on_tower_area_pressed():
	tower_manager.start_tower_placement(1)

func _on_tower_sniper_pressed():
	tower_manager.start_tower_placement(2)

func _on_tower_slow_pressed():
	tower_manager.start_tower_placement(3)

func _on_upgrade_pressed():
	tower_manager.upgrade_selected_tower()

func _on_sell_pressed():
	tower_manager.sell_selected_tower()
	update_upgrade_ui()

func _on_spawn_button_pressed():
	if not wave_manager.is_wave_in_progress():
		game_state.next_wave()
		if game_scene.has_node("UI/HUD/BuildPanel/BuildUI/SpawnButton") and game_scene.get_node("UI/HUD/BuildPanel/BuildUI/SpawnButton").has_node("StartSound"):
			game_scene.get_node("UI/HUD/BuildPanel/BuildUI/SpawnButton/StartSound").play()
		wave_manager.start_wave()
	else:
		print("Wave already in progress")

func _on_resume_pressed():
	toggle_pause_menu()

func _on_tower_selected(tower):
	if game_scene.has_node("UI/HUD/SelectedTower"):
		var selected_tower_ui = game_scene.get_node("UI/HUD/SelectedTower")
		selected_tower_ui.show()
		
		if selected_tower_ui.has_node("TowerTypeLabel"):
			selected_tower_ui.get_node("TowerTypeLabel").text = "Tower Type: " + str(tower_manager.get_tower_type(tower))
		
		if selected_tower_ui.has_node("TowerLevelLabel"):
			selected_tower_ui.get_node("TowerLevelLabel").text = "Level: " + str(tower_manager.get_tower_level(tower))
		
		if selected_tower_ui.has_node("TowerRangeLabel"):
			selected_tower_ui.get_node("TowerRangeLabel").text = "Range: " + str(tower_manager.get_tower_range(tower))
		
		if selected_tower_ui.has_node("TowerDamageLabel"):
			selected_tower_ui.get_node("TowerDamageLabel").text = "Damage: " + str(tower_manager.get_tower_damage(tower))
		
		if selected_tower_ui.has_node("TowerFireRateLabel"):
			selected_tower_ui.get_node("TowerFireRateLabel").text = "Fire Rate: " + str(tower_manager.get_tower_fire_rate(tower))

	update_upgrade_ui()

func _on_tower_deselected():
	if game_scene.has_node("UI/HUD/SelectedTower"):
		game_scene.get_node("UI/HUD/SelectedTower").hide()

	update_upgrade_ui()

func _on_wave_started():
	if game_scene.has_node("UI/HUD/BuildPanel/BuildUI/SpawnButton"):
		game_scene.get_node("UI/HUD/BuildPanel/BuildUI/SpawnButton").disabled = true
		game_scene.get_node("UI/HUD/BuildPanel/BuildUI/SpawnButton").modulate = Color(0.5, 0.5, 0.5, 1)
		if game_scene.get_node("UI/HUD/BuildPanel/BuildUI/SpawnButton").has_node("Image") and game_scene.get_node("UI/HUD/BuildPanel/BuildUI/SpawnButton/Image").has_node("Label"):
			game_scene.get_node("UI/HUD/BuildPanel/BuildUI/SpawnButton/Image/Label").text = "IN\nPROGRESS"

func _on_wave_completed():
	if game_scene.has_node("UI/HUD/BuildPanel/BuildUI/SpawnButton"):
		game_scene.get_node("UI/HUD/BuildPanel/BuildUI/SpawnButton").disabled = false
		game_scene.get_node("UI/HUD/BuildPanel/BuildUI/SpawnButton").modulate = Color(1, 1, 1, 1)
		if game_scene.get_node("UI/HUD/BuildPanel/BuildUI/SpawnButton").has_node("Image") and game_scene.get_node("UI/HUD/BuildPanel/BuildUI/SpawnButton/Image").has_node("Label"):
			game_scene.get_node("UI/HUD/BuildPanel/BuildUI/SpawnButton/Image/Label").text = "START\nWAVE " + str(game_state.current_wave + 1)

func show_game_over():
	game_scene.get_tree().paused = true
	
	var game_over_screen_scene = load("res://scenes/game_over_screen.tscn")
	var game_over_screen = game_over_screen_scene.instantiate()
	game_over_screen.set_wave_count(game_state.current_wave)
	game_over_screen.connect("restart_pressed", Callable(game_scene, "_on_restart_pressed"))
	game_over_screen.connect("main_menu_pressed", Callable(game_scene, "_on_main_menu_pressed"))
	
	game_scene.get_node("UI").add_child(game_over_screen)
	game_scene.get_node("AudioStreamPlayer").volume_db = -20.0

func toggle_pause_menu():
	var pause_menu = game_scene.get_node("UI/PauseMenu")
	if pause_menu.visible:
		pause_menu.hide()
		game_scene.get_tree().paused = false
		game_scene.resume_music()
	else:
		pause_menu.show()
		game_scene.get_tree().paused = true
		game_scene.pause_music()

func _on_talents_pressed():
	var talent_tree_scene = load("res://scenes/talent_tree_ui.tscn")
	var talent_tree = talent_tree_scene.instantiate()
	game_scene.get_node("UI").add_child(talent_tree)

func _on_talents_button_pressed():
	var talent_tree_scene = load("res://scenes/talent_tree_ui.tscn")
	var talent_tree = talent_tree_scene.instantiate()
	game_scene.get_node("UI").add_child(talent_tree)
