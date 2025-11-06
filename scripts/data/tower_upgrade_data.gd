extends Node

enum UpgradeType {
	DAMAGE,
	FIRE_RATE,
	RANGE,
	SPECIAL,
	NEW_TOWER
}

class UpgradeNode:
	var id: String
	var name: String
	var description: String
	var upgrade_type: UpgradeType
	var cost: int
	var prerequisites: Array[String]
	var tower_type: int
	var values: Dictionary
	var icon_path: String
	var position: Vector2
	
	func _init(
		p_id: String,
		p_name: String,
		p_description: String,
		p_type: UpgradeType,
		p_cost: int,
		p_prerequisites: Array[String],
		p_tower_type: int = -1,
		p_values: Dictionary = {},
		p_position: Vector2 = Vector2.ZERO
	):
		id = p_id
		name = p_name
		description = p_description
		upgrade_type = p_type
		cost = p_cost
		prerequisites = p_prerequisites
		tower_type = p_tower_type
		values = p_values
		position = p_position

var upgrade_nodes: Dictionary = {}

func _ready():
	_initialize_upgrade_tree()

func _initialize_upgrade_tree():
	upgrade_nodes = {}
	
	upgrade_nodes["basic_tower"] = UpgradeNode.new(
		"basic_tower",
		"Basic Tower",
		"Unlock the basic tower with standard damage and fire rate",
		UpgradeType.NEW_TOWER,
		0,
		[],
		0,
		{},
		Vector2(100, 300)
	)
	
	upgrade_nodes["basic_damage_1"] = UpgradeNode.new(
		"basic_damage_1",
		"Enhanced Bullets",
		"Increase basic tower damage by 25%",
		UpgradeType.DAMAGE,
		100,
		["basic_tower"],
		0,
		{"damage_mult": 1.25},
		Vector2(250, 200)
	)
	
	upgrade_nodes["basic_fire_rate_1"] = UpgradeNode.new(
		"basic_fire_rate_1",
		"Quick Reload",
		"Increase basic tower fire rate by 20%",
		UpgradeType.FIRE_RATE,
		150,
		["basic_tower"],
		0,
		{"fire_rate_mult": 0.8},
		Vector2(250, 400)
	)
	
	upgrade_nodes["basic_damage_2"] = UpgradeNode.new(
		"basic_damage_2",
		"Armor Piercing",
		"Increase basic tower damage by 50%",
		UpgradeType.DAMAGE,
		300,
		["basic_damage_1"],
		0,
		{"damage_mult": 1.5},
		Vector2(400, 150)
	)
	
	upgrade_nodes["basic_range_1"] = UpgradeNode.new(
		"basic_range_1",
		"Extended Barrel",
		"Increase basic tower range by 30%",
		UpgradeType.RANGE,
		200,
		["basic_damage_1", "basic_fire_rate_1"],
		0,
		{"range_mult": 1.3},
		Vector2(400, 300)
	)
	
	upgrade_nodes["rocket_tower"] = UpgradeNode.new(
		"rocket_tower",
		"Rocket Tower",
		"Unlock rocket tower with area damage",
		UpgradeType.NEW_TOWER,
		500,
		["basic_damage_2"],
		1,
		{},
		Vector2(550, 100)
	)
	
	upgrade_nodes["rocket_damage_1"] = UpgradeNode.new(
		"rocket_damage_1",
		"Explosive Payload",
		"Increase rocket damage by 30%",
		UpgradeType.DAMAGE,
		400,
		["rocket_tower"],
		1,
		{"damage_mult": 1.3},
		Vector2(700, 50)
	)
	
	upgrade_nodes["rocket_aoe"] = UpgradeNode.new(
		"rocket_aoe",
		"Cluster Bombs",
		"Increase rocket explosion radius by 40%",
		UpgradeType.SPECIAL,
		350,
		["rocket_tower"],
		1,
		{"aoe_mult": 1.4},
		Vector2(700, 150)
	)
	
	upgrade_nodes["sniper_tower"] = UpgradeNode.new(
		"sniper_tower",
		"Sniper Tower",
		"Unlock sniper tower with high damage and range",
		UpgradeType.NEW_TOWER,
		600,
		["basic_range_1"],
		2,
		{},
		Vector2(550, 300)
	)
	
	upgrade_nodes["sniper_damage_1"] = UpgradeNode.new(
		"sniper_damage_1",
		"Headshot",
		"Increase sniper damage by 50%",
		UpgradeType.DAMAGE,
		500,
		["sniper_tower"],
		2,
		{"damage_mult": 1.5},
		Vector2(700, 250)
	)
	
	upgrade_nodes["sniper_crit"] = UpgradeNode.new(
		"sniper_crit",
		"Critical Strike",
		"30% chance to deal double damage",
		UpgradeType.SPECIAL,
		600,
		["sniper_damage_1"],
		2,
		{"crit_chance": 0.3, "crit_mult": 2.0},
		Vector2(850, 250)
	)
	
	upgrade_nodes["ice_tower"] = UpgradeNode.new(
		"ice_tower",
		"Ice Tower",
		"Unlock ice tower that slows enemies",
		UpgradeType.NEW_TOWER,
		400,
		["basic_fire_rate_1"],
		3,
		{},
		Vector2(400, 450)
	)
	
	upgrade_nodes["ice_slow"] = UpgradeNode.new(
		"ice_slow",
		"Deep Freeze",
		"Increase slow effect by 30%",
		UpgradeType.SPECIAL,
		300,
		["ice_tower"],
		3,
		{"slow_mult": 1.3},
		Vector2(550, 500)
	)
	
	upgrade_nodes["ice_duration"] = UpgradeNode.new(
		"ice_duration",
		"Lasting Chill",
		"Increase slow duration by 50%",
		UpgradeType.SPECIAL,
		350,
		["ice_slow"],
		3,
		{"duration_mult": 1.5},
		Vector2(700, 500)
	)
	
	upgrade_nodes["multi_target"] = UpgradeNode.new(
		"multi_target",
		"Multi-targeting System",
		"All towers can target 2 enemies simultaneously",
		UpgradeType.SPECIAL,
		1000,
		["rocket_aoe", "sniper_crit", "ice_duration"],
		-1,
		{"multi_target": true},
		Vector2(850, 350)
	)

func get_upgrade_node(node_id: String) -> UpgradeNode:
	return upgrade_nodes.get(node_id, null)

func get_all_nodes() -> Dictionary:
	return upgrade_nodes

func get_node_connections() -> Array:
	var connections = []
	for node_id in upgrade_nodes:
		var node = upgrade_nodes[node_id]
		for prereq in node.prerequisites:
			connections.append({"from": prereq, "to": node_id})
	return connections
