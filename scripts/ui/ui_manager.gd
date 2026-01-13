extends Node

var game_scene
var game_state
var tower_manager
var wave_manager

var can_upgrade = false
var upgrade_cost = 0
var build_menu_visible = false
var game_speed = 1.0
var game_time = 0.0  

func _init(p_game_scene, p_game_state, p_tower_manager, p_wave_manager):
	game_scene = p_game_scene
	game_state = p_game_state
	tower_manager = p_tower_manager
	wave_manager = p_wave_manager
	
	game_speed = 1.0
	Engine.time_scale = 1.0
	
	game_state.connect("money_changed", Callable(self, "update_money_ui"))
	game_state.connect("lives_changed", Callable(self, "update_lives_ui"))
	game_state.connect("wave_changed", Callable(self, "update_wave_ui"))
	game_state.connect("game_over", Callable(self, "show_game_over"))
	
	tower_manager.connect("tower_selected", Callable(self, "_on_tower_selected"))
	tower_manager.connect("tower_deselected", Callable(self, "_on_tower_deselected"))
	tower_manager.connect("insufficient_funds", Callable(self, "_on_insufficient_funds"))
	
	wave_manager.connect("wave_started", Callable(self, "_on_wave_started"))
	wave_manager.connect("wave_completed", Callable(self, "_on_wave_completed"))
	
	call_deferred("update_campaign_info")

func _process(_delta):
	var real_delta = _delta / Engine.time_scale
	game_time += real_delta
	update_timer_ui()
	
	if tower_manager.get_selected_tower():
		var selected_tower = tower_manager.get_selected_tower()
		can_upgrade = selected_tower.can_upgrade()
		upgrade_cost = tower_manager.get_upgrade_cost()
	else:
		can_upgrade = false
	
	update_upgrade_ui()

func _input(event):
	if event is InputEventKey and event.pressed and not event.echo:
		if not _is_typing_in_text_field():
			match event.keycode:
				KEY_1:
					_on_tower_basic_pressed()
				KEY_2:
					_on_tower_area_pressed()
				KEY_3:
					_on_tower_sniper_pressed()
				KEY_4:
					_on_tower_slow_pressed()
				KEY_5:
					_on_tower_machine_gun_pressed()
				KEY_6:
					_on_tower_magic_pressed()
				KEY_U:
					if tower_manager.get_selected_tower() and can_upgrade:
						_on_upgrade_pressed()
				KEY_S:
					if tower_manager.get_selected_tower():
						_on_sell_pressed()
				KEY_SPACE:
					if not wave_manager.is_wave_in_progress():
						_on_spawn_button_pressed()

func _is_typing_in_text_field() -> bool:
	var focused = game_scene.get_viewport().gui_get_focus_owner()
	return focused is LineEdit or focused is TextEdit

func connect_ui_buttons():
	if game_scene.has_node("UI/HUD/BuildPanel"):
		game_scene.get_node("UI/HUD/BuildPanel").visible = false
	
	if game_scene.has_node("UI/HUD/BuildPanel/BuildUI/TowerBasic"):
		game_scene.get_node("UI/HUD/BuildPanel/BuildUI/TowerBasic").connect("pressed", Callable(self, "_on_tower_basic_pressed"))
	
	if game_scene.has_node("UI/HUD/BuildPanel/BuildUI/TowerArea"):
		game_scene.get_node("UI/HUD/BuildPanel/BuildUI/TowerArea").connect("pressed", Callable(self, "_on_tower_area_pressed"))
	
	if game_scene.has_node("UI/HUD/BuildPanel/BuildUI/TowerSniper"):
		game_scene.get_node("UI/HUD/BuildPanel/BuildUI/TowerSniper").connect("pressed", Callable(self, "_on_tower_sniper_pressed"))
	
	if game_scene.has_node("UI/HUD/BuildPanel/BuildUI/TowerSlow"):
		game_scene.get_node("UI/HUD/BuildPanel/BuildUI/TowerSlow").connect("pressed", Callable(self, "_on_tower_slow_pressed"))
	
	if game_scene.has_node("UI/HUD/BuildPanel/BuildUI/TowerMachineGun"):
		game_scene.get_node("UI/HUD/BuildPanel/BuildUI/TowerMachineGun").connect("pressed", Callable(self, "_on_tower_machine_gun_pressed"))
	
	if game_scene.has_node("UI/HUD/BuildPanel/BuildUI/TowerMagic"):
		game_scene.get_node("UI/HUD/BuildPanel/BuildUI/TowerMagic").connect("pressed", Callable(self, "_on_tower_magic_pressed"))
	
	if game_scene.has_node("UI/HUD/BuildPanel/BuildUI/Upgrade"):
		game_scene.get_node("UI/HUD/BuildPanel/BuildUI/Upgrade").connect("pressed", Callable(self, "_on_upgrade_pressed"))
	
	if game_scene.has_node("UI/HUD/BuildPanel/BuildUI/SpawnButton"):
		game_scene.get_node("UI/HUD/BuildPanel/BuildUI/SpawnButton").connect("pressed", Callable(self, "_on_spawn_button_pressed"))
	
	if game_scene.has_node("UI/HUD/BuildPanel/BuildUI/Sell"):
		game_scene.get_node("UI/HUD/BuildPanel/BuildUI/Sell").connect("pressed", Callable(self, "_on_sell_pressed"))
	
	if game_scene.has_node("UI/PauseMenu"):
		var pause_menu = game_scene.get_node("UI/PauseMenu")
		pause_menu.connect("resume_pressed", Callable(self, "_on_resume_pressed"))
		pause_menu.connect("settings_pressed", Callable(self, "_on_pause_settings_pressed"))
		pause_menu.connect("upgrades_pressed", Callable(self, "_on_pause_upgrades_pressed"))
		pause_menu.connect("main_menu_pressed", Callable(game_scene, "_on_main_menu_pressed"))
	
	if game_scene.has_node("UI/HUD/SpeedButton"):
		game_scene.get_node("UI/HUD/SpeedButton").connect("pressed", Callable(self, "_on_speed_button_pressed"))
	
	if game_scene.has_node("UI/HUD/HotkeysPanel/ToggleButton"):
		game_scene.get_node("UI/HUD/HotkeysPanel/ToggleButton").connect("pressed", Callable(self, "_on_toggle_hotkeys_panel"))

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
	
	var wave_text = "Wave: " + str(wave_number)
	
	if GameModeManager.is_campaign():
		var max_waves = wave_manager.max_waves if wave_manager else -1
		if max_waves > 0:
			wave_text = "Wave: " + str(wave_number) + "/" + str(max_waves)
	
	if game_scene.has_node("UI/HUD/InfoPanel/UserUI/WaveContainer/WaveLabel"):
		game_scene.get_node("UI/HUD/InfoPanel/UserUI/WaveContainer/WaveLabel").text = wave_text

func update_timer_ui():
	if not game_scene.has_node("UI/HUD/InfoPanel/UserUI/TimeContainer"):
		return
	
	var minutes = int(game_time) / 60
	var seconds = int(game_time) % 60
	var time_text = "Time: %02d:%02d" % [minutes, seconds]
	
	if game_scene.has_node("UI/HUD/InfoPanel/UserUI/TimeContainer/TimeLabel"):
		game_scene.get_node("UI/HUD/InfoPanel/UserUI/TimeContainer/TimeLabel").text = time_text

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

func _on_tower_machine_gun_pressed():
	tower_manager.start_tower_placement(4)

func _on_tower_magic_pressed():
	tower_manager.start_tower_placement(5)

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

func _on_resume_pressed():
	toggle_pause_menu()

func _on_pause_settings_pressed():
	if game_scene.has_node("UI/PauseMenu"):
		game_scene.get_node("UI/PauseMenu").hide()
	
	var settings_scene = load("res://scenes/settings_menu.tscn")
	var settings_menu = settings_scene.instantiate()
	settings_menu.connect("back_pressed", Callable(self, "_on_pause_settings_back"))
	game_scene.get_node("UI").add_child(settings_menu)

func _on_pause_settings_back():
	var ui_node = game_scene.get_node("UI")
	for child in ui_node.get_children():
		if child.name == "SettingsMenu":
			child.queue_free()
			break
	
	if game_scene.has_node("UI/PauseMenu"):
		game_scene.get_node("UI/PauseMenu").show()

func _on_pause_upgrades_pressed():
	if game_scene.has_node("UI/PauseMenu"):
		game_scene.get_node("UI/PauseMenu").hide()
	
	var upgrade_menu_scene = load("res://scenes/tower_upgrade_menu.tscn")
	var upgrade_menu = upgrade_menu_scene.instantiate()
	upgrade_menu.connect("closed", Callable(self, "_on_pause_upgrades_back"))
	game_scene.get_node("UI").add_child(upgrade_menu)

func _on_pause_upgrades_back():
	var ui_node = game_scene.get_node("UI")
	for child in ui_node.get_children():
		if child.name == "TowerUpgradeMenu":
			child.queue_free()
			break
	
	if game_scene.has_node("UI/PauseMenu"):
		game_scene.get_node("UI/PauseMenu").show()

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

func _on_insufficient_funds(cost):
	show_notification("Not enough money! Price: " + str(cost))

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

func toggle_build_menu():
	if game_scene.has_node("UI/HUD/BuildPanel"):
		var build_panel = game_scene.get_node("UI/HUD/BuildPanel")
		build_menu_visible = !build_menu_visible
		build_panel.visible = build_menu_visible

func _on_speed_button_pressed():
	if game_speed == 1.0:
		game_speed = 2.0
	elif game_speed == 2.0:
		game_speed = 4.0
	else:
		game_speed = 1.0
	Engine.time_scale = game_speed
	
	if game_scene.has_node("UI/HUD/SpeedButton/SpeedLabel"):
		var speed_text = "Speed: " + str(int(game_speed)) + "x"
		game_scene.get_node("UI/HUD/SpeedButton/SpeedLabel").text = speed_text
	
	if game_scene.has_node("ButtonSound"):
		game_scene.get_node("ButtonSound").play()

func _on_toggle_hotkeys_panel():
	if game_scene.has_node("UI/HUD/HotkeysPanel"):
		var panel = game_scene.get_node("UI/HUD/HotkeysPanel")
		var toggle_btn = game_scene.get_node("UI/HUD/HotkeysPanel/ToggleButton")
		var hotkeys_list = game_scene.get_node("UI/HUD/HotkeysPanel/HotkeysList")
		
		hotkeys_list.visible = !hotkeys_list.visible
		
		if hotkeys_list.visible:
			toggle_btn.text = "−"
			panel.custom_minimum_size = Vector2(200, 220)
			panel.offset_top = -240.0
			panel.offset_left = 20.0
			panel.offset_right = 220.0
		else:
			toggle_btn.text = "+"
			panel.custom_minimum_size = Vector2(200, 35)
			panel.offset_top = -55.0
			panel.offset_left = 20.0
			panel.offset_right = 220.0

func show_notification(message: String, duration: float = 2.0):
	if game_scene.has_node("UI/HUD/NotificationLabel"):
		var notification_label = game_scene.get_node("UI/HUD/NotificationLabel")
		notification_label.text = message
		notification_label.visible = true
		
		var timer = game_scene.get_tree().create_timer(duration)
		timer.timeout.connect(func(): 
			if notification_label:
				notification_label.visible = false
		)

func update_campaign_info():
	if not GameModeManager.is_campaign():
		return
	
	var level_number = GameModeManager.get_campaign_level()
	var level = CampaignLevel.get_level(level_number)
	
	if level and game_scene.has_node("UI/HUD/InfoPanel"):
		var info_panel = game_scene.get_node("UI/HUD/InfoPanel")
		var info_title = game_scene.get_node("UI/HUD/InfoPanel/InfoTitle")
		
		if not info_panel.has_node("LevelNameLabel"):
			var level_name_label = Label.new()
			level_name_label.name = "LevelNameLabel"
			level_name_label.text = level.level_name
			level_name_label.add_theme_font_size_override("font_size", 16)
			level_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			info_panel.add_child(level_name_label)
			level_name_label.set_anchors_preset(Control.PRESET_TOP_WIDE)
			level_name_label.offset_top = 22
			level_name_label.offset_bottom = 38
			
			info_title.offset_bottom = 22
