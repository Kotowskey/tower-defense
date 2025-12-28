extends GutTest

const UpgradeCurrencyManagerScript := preload("res://scripts/managers/upgrade_currency_manager.gd")

func after_each():
	_cleanup_user_file("user://upgrade_currency.save")

func _cleanup_user_file(user_path: String) -> void:
	if not FileAccess.file_exists(user_path):
		return
	var dir := DirAccess.open("user://")
	if dir:
		dir.remove(user_path.get_file())

func test_add_and_spend_points_changes_balance():
	var mgr = UpgradeCurrencyManagerScript.new()
	mgr.reset_points()

	mgr.add_upgrade_points(10)
	assert_eq(mgr.get_upgrade_points(), 10)

	assert_true(mgr.spend_upgrade_points(7))
	assert_eq(mgr.get_upgrade_points(), 3)

	assert_false(mgr.spend_upgrade_points(5), "Nie powinno pozwolić na zejście poniżej 0")
	assert_eq(mgr.get_upgrade_points(), 3)

func test_currency_changed_signal_emitted_on_add():
	var mgr = UpgradeCurrencyManagerScript.new()
	mgr.reset_points()
	watch_signals(mgr)

	mgr.add_upgrade_points(1)
	assert_signal_emitted(mgr, "currency_changed")
