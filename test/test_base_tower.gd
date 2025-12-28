extends GutTest

const BaseTowerScript := preload("res://scripts/towers/base_tower.gd")

class FakeUpgradeTree:
	enum UpgradeType { DAMAGE, FIRE_RATE, RANGE, SPECIAL }
	func get_tower_bonus(_tower_type: String, upgrade_type: int) -> float:
		match upgrade_type:
			UpgradeType.DAMAGE:
				return 0.5 # +50%
			UpgradeType.FIRE_RATE:
				return 1.0 # +100% => fire_rate / 2
			UpgradeType.RANGE:
				return 0.2 # +20%
			_:
				return 0.0

func test_can_upgrade_depends_on_level_and_max():
	var tower = BaseTowerScript.new()
	tower.tower_level = 1
	tower.max_level = 3
	assert_true(tower.can_upgrade())

	tower.tower_level = 3
	assert_false(tower.can_upgrade())

func test_get_upgrade_cost_scales_with_level():
	var tower = BaseTowerScript.new()
	tower.tower_cost = 100
	tower.tower_level = 2
	assert_eq(tower.get_upgrade_cost(), 200)

func test_apply_permanent_upgrades_changes_stats_from_base():
	var tower = BaseTowerScript.new()
	tower.tower_upgrade_tree = FakeUpgradeTree.new()

	tower.base_damage = 10
	tower.base_fire_rate = 1.0
	tower.base_range = 100.0

	tower.tower_damage = 10
	tower.tower_fire_rate = 1.0
	tower.tower_range = 100.0

	tower.apply_permanent_upgrades()

	assert_eq(tower.tower_damage, 15)
	assert_almost_eq(tower.tower_fire_rate, 0.5, 0.0001)
	assert_almost_eq(tower.tower_range, 120.0, 0.0001)
