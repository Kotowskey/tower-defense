extends Control

func _ready():
	visible = false

func set_tower_info(tower_name: String, tower_level: int, tower_damage: int, tower_range: float, 
					tower_fire_rate: float, has_slow: bool = false, slow_factor: float = 0.0):
	if has_node("VBoxContainer/InfoContainer/TowerName"):
		$VBoxContainer/InfoContainer/TowerName.text = "Name: " + tower_name
		
	if has_node("VBoxContainer/InfoContainer/TowerLevel"):
		$VBoxContainer/InfoContainer/TowerLevel.text = "Level: " + str(tower_level)
		
	if has_node("VBoxContainer/InfoContainer/TowerDamage"):
		$VBoxContainer/InfoContainer/TowerDamage.text = "Damage: " + str(tower_damage)
		
	if has_node("VBoxContainer/InfoContainer/TowerRange"):
		$VBoxContainer/InfoContainer/TowerRange.text = "Range: " + str(tower_range)
		
	if has_node("VBoxContainer/InfoContainer/TowerFireRate"):
		$VBoxContainer/InfoContainer/TowerFireRate.text = "Fire Rate: " + str(tower_fire_rate) + "/s"
		
	if has_node("VBoxContainer/InfoContainer/TowerSpecial"):
		if has_slow:
			$VBoxContainer/InfoContainer/TowerSpecial.text = "Slow: " + str(int((1.0 - slow_factor) * 100)) + "%"
			$VBoxContainer/InfoContainer/TowerSpecial.visible = true
		else:
			$VBoxContainer/InfoContainer/TowerSpecial.visible = false
