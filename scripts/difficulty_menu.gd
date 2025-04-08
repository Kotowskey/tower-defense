extends Control

signal difficulty_selected(level)
signal back_pressed

func _ready():
	# Podłączanie przycisków
	$VBoxContainer/EASY.connect("pressed", Callable(self, "_on_easy_pressed"))
	$VBoxContainer/NORMAL.connect("pressed", Callable(self, "_on_normal_pressed"))
	$VBoxContainer/HARD.connect("pressed", Callable(self, "_on_hard_pressed"))
	$VBoxContainer/BACK.connect("pressed", Callable(self, "_on_back_pressed"))

func _on_easy_pressed():
	emit_signal("difficulty_selected", 0)

func _on_normal_pressed():
	emit_signal("difficulty_selected", 1)

func _on_hard_pressed():
	emit_signal("difficulty_selected", 2)
	
func _on_back_pressed():
	emit_signal("back_pressed")
