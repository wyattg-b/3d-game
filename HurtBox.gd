extends Area3D

@export var owner_path: NodePath = NodePath("..")
@onready var owner_node: Node = get_node(owner_path)

func _ready() -> void:
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area3D) -> void:
	# Only accept our player hitbox
	if not area.is_in_group("player_hitbox"):
		return

	# Only if the hitbox is active (swinging)
	if area.has_method("is_active") and not area.is_active():
		return

	var dmg: int = area.get_damage()
	if owner_node.has_method("take_damage"):
		owner_node.take_damage(dmg)
	else:
		push_error("HurtBox owner has no take_damage(): " + str(owner_node))
