extends GutTest

const TowerUpgradeTreeScript := preload("res://scripts/managers/tower_upgrade_tree.gd")

func after_each():
	_cleanup_user_file("user://tower_upgrades.save")

func _cleanup_user_file(user_path: String) -> void:
	if not FileAccess.file_exists(user_path):
		return
	var dir := DirAccess.open("user://")
	if dir:
		dir.remove(user_path.get_file())

func test_can_unlock_requires_chain():
	var tree = TowerUpgradeTreeScript.new()
	assert_false(tree.can_unlock_upgrade("basic", 1), "Upgrade 1 wymaga upgrade 0")
	assert_true(tree.can_unlock_upgrade("basic", 0), "Upgrade 0 nie ma wymagań")
	assert_true(tree.unlock_upgrade("basic", 0), "Powinno się odblokować upgrade 0")
	assert_true(tree.is_upgrade_unlocked("basic", 0))
	assert_true(tree.can_unlock_upgrade("basic", 1), "Po odblokowaniu 0, upgrade 1 powinien być dostępny")

func test_get_tower_bonus_sums_unlocked_values():
	var tree = TowerUpgradeTreeScript.new()
	var UpgradeType = tree.UpgradeType

	assert_true(tree.unlock_upgrade("basic", 0))
	assert_true(tree.unlock_upgrade("basic", 1))

	var bonus := tree.get_tower_bonus("basic", UpgradeType.DAMAGE)
	assert_almost_eq(bonus, 0.25, 0.0001, "0.10 + 0.15 = 0.25")

func test_special_upgrade_requires_multiple_paths():
	var tree = TowerUpgradeTreeScript.new()

	assert_false(tree.has_special_upgrade("basic"))
	assert_false(tree.can_unlock_upgrade("basic", 8), "Special wymaga 2 i 5")

	# Odblokuj Damage I->II->III (0->1->2)
	assert_true(tree.unlock_upgrade("basic", 0))
	assert_true(tree.unlock_upgrade("basic", 1))
	assert_true(tree.unlock_upgrade("basic", 2))

	# Odblokuj FireRate I->II->III (3->4->5)
	assert_true(tree.unlock_upgrade("basic", 3))
	assert_true(tree.unlock_upgrade("basic", 4))
	assert_true(tree.unlock_upgrade("basic", 5))

	assert_true(tree.can_unlock_upgrade("basic", 8))
	assert_true(tree.unlock_upgrade("basic", 8))
	assert_true(tree.has_special_upgrade("basic"))
	assert_eq(tree.get_special_upgrade_value("basic"), 2.0)
