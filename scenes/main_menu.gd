extends Control

func _ready():
	$Play.pressed.connect(_on_play_pressed)
	$Options.pressed.connect(_on_options_pressed)
	$Quit.pressed.connect(_on_quit_pressed)

func _on_play_pressed():
	get_tree().change_scene_to_file("res://scenes/ModeSelect.tscn")

func _on_options_pressed():
	get_tree().change_scene_to_file("res://scenes/options_menu.tscn")

func _on_quit_pressed():
	get_tree().quit()
