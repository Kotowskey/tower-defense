extends Control

func _ready():
	visible = false

func set_tower_info(tower_name: String, tower_level: int, tower_damage: int, tower_range: float, 
					tower_fire_rate: float, has_slow: bool = false, slow_factor: float = 0.0):
	if has_node("VBoxContainer/TowerName"):
		$VBoxContainer/TowerName.text = "Name: " + tower_name
		
	if has_node("VBoxContainer/TowerLevel"):
		$VBoxContainer/TowerLevel.text = "Level: " + str(tower_level)
		
	if has_node("VBoxContainer/TowerDamage"):
		$VBoxContainer/TowerDamage.text = "Damage: " + str(tower_damage)
		
	if has_node("VBoxContainer/TowerRange"):
		$VBoxContainer/TowerRange.text = "Range: " + str(tower_range)
		
	if has_node("VBoxContainer/TowerFireRate"):
		$VBoxContainer/TowerFireRate.text = "Fire Rate: " + str(tower_fire_rate) + "/s"
		
	if has_node("VBoxContainer/TowerSpecial"):
		if has_slow:
			$VBoxContainer/TowerSpecial.text = "Slow: " + str(int((1.0 - slow_factor) * 100)) + "%"
			$VBoxContainer/TowerSpecial.visible = true
		else:
			$VBoxContainer/TowerSpecial.visible = false
