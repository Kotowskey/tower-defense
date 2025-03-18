extends Node2D

var tower_scene = preload("res://scenes/tower.tscn")
var building_mode = false
var tower_preview = null
var player_money = 500

func _ready():
	$UI/HUD/BuildUI/Tower.connect("pressed", Callable(self, "_on_tower_button_pressed"))
	
	if not $UI/HUD.has_node("MoneyLabel"):
		var money_label = Label.new()
		money_label.name = "MoneyLabel"
		money_label.text = "Money: " + str(player_money)
		money_label.position = Vector2(20, 20)
		$UI/HUD.add_child(money_label)
	
	update_money_ui()

func _process(delta):
	if building_mode and tower_preview:
		var mouse_pos = get_global_mouse_position()
		tower_preview.position = mouse_pos

func _on_tower_button_pressed():
	print("Tower button pressed")
	building_mode = true
	
	if tower_preview:
		tower_preview.queue_free()
	
	tower_preview = tower_scene.instantiate()
	tower_preview.modulate = Color(1, 1, 1, 0.5)
	add_child(tower_preview)

func _unhandled_input(event):
	if not building_mode:
		return
		
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var mouse_pos = get_global_mouse_position()
			if player_money >= 100:
				place_tower(mouse_pos)
				player_money -= 100
				update_money_ui()
			print("Tower placed at: ", mouse_pos)
		
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			cancel_building()
			print("Building cancelled")

func place_tower(pos):
	var new_tower = tower_scene.instantiate()
	new_tower.position = pos
	
	if $Map.has_node("Turrets"):
		$Map/Turrets.add_child(new_tower)
	else:
		$Map.add_child(new_tower)
	
	cancel_building()

func cancel_building():
	building_mode = false
	if tower_preview:
		tower_preview.queue_free()
		tower_preview = null

func update_money_ui():
	if $UI/HUD.has_node("MoneyLabel"):
		$UI/HUD/MoneyLabel.text = "Money: " + str(player_money)
