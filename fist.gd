extends Area3D

@export var damage_amount: int = 10
var can_deal_damage: bool = false
var targets_hit: Dictionary = {}

@onready var shape: CollisionShape3D = get_node_or_null("CollisionShape3D") as CollisionShape3D

func _ready() -> void:
	add_to_group("player_hitbox")
	area_entered.connect(_on_area_entered)

	if shape == null:
		push_error("fist: Missing child CollisionShape3D (must be named exactly 'CollisionShape3D').")
		return

	can_deal_damage = false
	targets_hit.clear()
	shape.disabled = true  # FORCE OFF at start

func is_hitbox() -> bool:
	return true

func is_active() -> bool:
	return can_deal_damage

func get_damage() -> int:
	return damage_amount

func start_swing() -> void:
	can_deal_damage = true
	targets_hit.clear()
	if shape:
		shape.disabled = false

func end_swing() -> void:
	can_deal_damage = false
	if shape:
		shape.disabled = true

func _on_area_entered(area: Area3D) -> void:
	# only used for debugging overlap; damage is applied by HurtBox.gd
	if can_deal_damage:
		print("fist overlapped:", area.name)
