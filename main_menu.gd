extends Control

@export_file("*.tscn")
var game_scene_path: String = "res://main.tscn"


func _ready() -> void:
	# Connect button signals here (if you don't want to connect in the editor).
	$VBoxContainer/start.pressed.connect(_on_play_button_pressed)
	$VBoxContainer/QUIT.pressed.connect(_on_quit_button_pressed)


func _on_play_button_pressed() -> void:
	if game_scene_path != "":
		get_tree().change_scene_to_file(game_scene_path)


func _on_quit_button_pressed() -> void:
	get_tree().quit()
