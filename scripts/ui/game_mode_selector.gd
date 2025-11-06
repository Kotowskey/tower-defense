extends Control

signal mode_selected(mode)
signal back_pressed

func _ready():
	$MarginContainer/VBoxContainer/CampaignButton.connect("pressed", Callable(self, "_on_campaign_pressed"))
	$MarginContainer/VBoxContainer/SandboxButton.connect("pressed", Callable(self, "_on_sandbox_pressed"))
	$MarginContainer/VBoxContainer/BackButton.connect("pressed", Callable(self, "_on_back_pressed"))

func _on_campaign_pressed():
	emit_signal("mode_selected", 1)

func _on_sandbox_pressed():
	emit_signal("mode_selected", 0)

func _on_back_pressed():
	emit_signal("back_pressed")
