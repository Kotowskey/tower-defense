extends Control

signal back_pressed

var current_category = "towers" # "towers" or "enemies"
var current_selection = null

var tower_data = {
	"basic": {
		"name": "Basic Tower",
		"cost": 100,
		"damage": 10,
		"fire_rate": 1.0,
		"range": 300,
		"description": "Standard tower. Solid and versatile, ideal for early game. Relatively low cost allows for quick defense buildup.",
		"special": "No special effects"
	},
	"ice": {
		"name": "Ice Tower",
		"cost": 150,
		"damage": 5,
		"fire_rate": 1.0,
		"range": 250,
		"description": "Ice tower slows down enemies. Low damage compensated by slowing effect, which makes it easier for other towers to attack.",
		"special": "Slows enemies by 50% for 2 seconds"
	},
	"rocket": {
		"name": "Rocket Tower",
		"cost": 200,
		"damage": 30,
		"fire_rate": 2.0,
		"range": 250,
		"description": "Rocket tower deals high area damage. Slower fire rate, but excellent against groups of enemies.",
		"special": "Area damage on impact"
	},
	"sniper": {
		"name": "Sniper Tower",
		"cost": 300,
		"damage": 30,
		"fire_rate": 2.0,
		"range": 500,
		"description": "Sniper tower with the longest range. High cost, but excellent for eliminating threats from a safe distance.",
		"special": "Longest range in the game"
	}
}

var enemy_data = {
	"basic": {
		"name": "Basic Enemy",
		"health": 25,
		"speed": 300,
		"value": 25,
		"description": "Standard enemy. Balanced stats making it a moderate threat. Appears in all waves.",
		"weakness": "Vulnerable to all tower types"
	},
	"fast": {
		"name": "Fast Enemy",
		"health": 15,
		"speed": 450,
		"value": 35,
		"description": "Fast and agile enemy. Low health, but high speed makes it hard to target. Requires towers with fast fire rate.",
		"weakness": "Low durability, vulnerable to rapid attacks"
	},
	"tank": {
		"name": "Tank",
		"health": 50,
		"speed": 200,
		"value": 45,
		"description": "Heavily armored enemy. Slow but very durable. Requires concentrated fire from multiple towers to destroy.",
		"weakness": "Low speed makes it easy to target"
	},
	"boss": {
		"name": "Boss",
		"health": 200,
		"speed": 150,
		"value": 100,
		"description": "Powerful boss appearing every few waves. Massive health and reward value. Requires full defensive power to defeat.",
		"weakness": "Very slow movement"
	}
}

func _ready():
	setup_ui()
	show_towers()
	
	if has_node("Panel/VBoxContainer/BackButton"):
		$Panel/VBoxContainer/BackButton.connect("pressed", Callable(self, "_on_back_pressed"))

func setup_ui():
	# Connect category buttons
	if has_node("Panel/VBoxContainer/CategoryButtons/TowersButton"):
		$Panel/VBoxContainer/CategoryButtons/TowersButton.connect("pressed", Callable(self, "_on_towers_button_pressed"))
	
	if has_node("Panel/VBoxContainer/CategoryButtons/EnemiesButton"):
		$Panel/VBoxContainer/CategoryButtons/EnemiesButton.connect("pressed", Callable(self, "_on_enemies_button_pressed"))
	
	# Connect tower buttons
	var tower_types = ["basic", "ice", "rocket", "sniper"]
	for tower_type in tower_types:
		var button_path = "Panel/VBoxContainer/Content/TowerList/" + tower_type.capitalize() + "Button"
		if has_node(button_path):
			get_node(button_path).connect("pressed", Callable(self, "_on_tower_selected").bind(tower_type))
	
	# Connect enemy buttons
	var enemy_types = ["basic", "fast", "tank", "boss"]
	for enemy_type in enemy_types:
		var button_path = "Panel/VBoxContainer/Content/EnemyList/" + enemy_type.capitalize() + "Button"
		if has_node(button_path):
			get_node(button_path).connect("pressed", Callable(self, "_on_enemy_selected").bind(enemy_type))

func show_towers():
	current_category = "towers"
	
	if has_node("Panel/VBoxContainer/Content/TowerList"):
		$Panel/VBoxContainer/Content/TowerList.visible = true
	if has_node("Panel/VBoxContainer/Content/EnemyList"):
		$Panel/VBoxContainer/Content/EnemyList.visible = false
	if has_node("Panel/VBoxContainer/Content/DetailPanel"):
		$Panel/VBoxContainer/Content/DetailPanel.visible = false
	
	# Highlight towers button
	if has_node("Panel/VBoxContainer/CategoryButtons/TowersButton"):
		$Panel/VBoxContainer/CategoryButtons/TowersButton.disabled = true
	if has_node("Panel/VBoxContainer/CategoryButtons/EnemiesButton"):
		$Panel/VBoxContainer/CategoryButtons/EnemiesButton.disabled = false

func show_enemies():
	current_category = "enemies"
	
	if has_node("Panel/VBoxContainer/Content/TowerList"):
		$Panel/VBoxContainer/Content/TowerList.visible = false
	if has_node("Panel/VBoxContainer/Content/EnemyList"):
		$Panel/VBoxContainer/Content/EnemyList.visible = true
	if has_node("Panel/VBoxContainer/Content/DetailPanel"):
		$Panel/VBoxContainer/Content/DetailPanel.visible = false
	
	# Highlight enemies button
	if has_node("Panel/VBoxContainer/CategoryButtons/TowersButton"):
		$Panel/VBoxContainer/CategoryButtons/TowersButton.disabled = false
	if has_node("Panel/VBoxContainer/CategoryButtons/EnemiesButton"):
		$Panel/VBoxContainer/CategoryButtons/EnemiesButton.disabled = true

func _on_towers_button_pressed():
	show_towers()

func _on_enemies_button_pressed():
	show_enemies()

func _on_tower_selected(tower_type: String):
	current_selection = tower_type
	var data = tower_data[tower_type]
	
	show_detail_panel()
	
	if has_node("Panel/VBoxContainer/Content/DetailPanel/Details/NameLabel"):
		$Panel/VBoxContainer/Content/DetailPanel/Details/NameLabel.text = data.name
	
	if has_node("Panel/VBoxContainer/Content/DetailPanel/Details/StatsLabel"):
		var stats_text = "Cost: " + str(data.cost) + " gold\n"
		stats_text += "Damage: " + str(data.damage) + "\n"
		stats_text += "Fire Rate: " + str(data.fire_rate) + " s\n"
		stats_text += "Range: " + str(data.range) + " px"
		$Panel/VBoxContainer/Content/DetailPanel/Details/StatsLabel.text = stats_text
	
	if has_node("Panel/VBoxContainer/Content/DetailPanel/Details/DescriptionLabel"):
		$Panel/VBoxContainer/Content/DetailPanel/Details/DescriptionLabel.text = data.description
	
	if has_node("Panel/VBoxContainer/Content/DetailPanel/Details/SpecialLabel"):
		$Panel/VBoxContainer/Content/DetailPanel/Details/SpecialLabel.text = "Special: " + data.special

func _on_enemy_selected(enemy_type: String):
	current_selection = enemy_type
	var data = enemy_data[enemy_type]
	
	show_detail_panel()
	
	if has_node("Panel/VBoxContainer/Content/DetailPanel/Details/NameLabel"):
		$Panel/VBoxContainer/Content/DetailPanel/Details/NameLabel.text = data.name
	
	if has_node("Panel/VBoxContainer/Content/DetailPanel/Details/StatsLabel"):
		var stats_text = "Health: " + str(data.health) + " HP\n"
		stats_text += "Speed: " + str(data.speed) + "\n"
		stats_text += "Reward: " + str(data.value) + " gold"
		$Panel/VBoxContainer/Content/DetailPanel/Details/StatsLabel.text = stats_text
	
	if has_node("Panel/VBoxContainer/Content/DetailPanel/Details/DescriptionLabel"):
		$Panel/VBoxContainer/Content/DetailPanel/Details/DescriptionLabel.text = data.description
	
	if has_node("Panel/VBoxContainer/Content/DetailPanel/Details/SpecialLabel"):
		$Panel/VBoxContainer/Content/DetailPanel/Details/SpecialLabel.text = "Weakness: " + data.weakness

func show_detail_panel():
	if has_node("Panel/VBoxContainer/Content/TowerList"):
		$Panel/VBoxContainer/Content/TowerList.visible = false
	if has_node("Panel/VBoxContainer/Content/EnemyList"):
		$Panel/VBoxContainer/Content/EnemyList.visible = false
	if has_node("Panel/VBoxContainer/Content/DetailPanel"):
		$Panel/VBoxContainer/Content/DetailPanel.visible = true

func _on_back_pressed():
	if has_node("Panel/VBoxContainer/Content/DetailPanel") and $Panel/VBoxContainer/Content/DetailPanel.visible:
		# Go back to list view
		if current_category == "towers":
			show_towers()
		else:
			show_enemies()
	else:
		# Go back to main menu
		emit_signal("back_pressed")
