# CameraPivot.gd (attach to Player/CameraPivot)
extends Node3D

@export var mouse_sensitivity: float = 0.002
@export var pitch_min_deg: float = -80.0
@export var pitch_max_deg: float = 80.0

@onready var player: CharacterBody3D = get_parent() as CharacterBody3D
@onready var cam: Camera3D = $Camera3D

var pitch: float = 0.0

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		# Yaw rotates the PLAYER (not the camera pivot)
		player.rotate_y(-event.relative.x * mouse_sensitivity)

		# Pitch rotates the CAMERA only
		pitch -= event.relative.y * mouse_sensitivity
		pitch = clamp(pitch, deg_to_rad(pitch_min_deg), deg_to_rad(pitch_max_deg))
		cam.rotation.x = pitch
