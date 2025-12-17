extends Node3D

@export_file("*.tscn")
var main_menu_scene_path: String = "res://scenes/main_menu.tscn"

@onready var player: Node = get_node_or_null("Player")
@onready var hud: Node = get_node_or_null("HUD")

func _ready() -> void:
	if player == null:
		push_error("World: Missing 'Player' node.")
		return

	if hud == null:
		push_error("World: Missing 'HUD' node.")
	else:
		if hud.has_method("connect_to_player"):
			hud.connect_to_player(player)
		else:
			push_error("World: HUD missing connect_to_player().")

	get_tree().call_group("enemies", "set_player", player)

	if player.has_signal("died"):
		player.died.connect(_on_player_died)

func _on_player_died() -> void:
	print("World: Player died -> returning to main menu")
	get_tree().change_scene_to_file(main_menu_scene_path)
