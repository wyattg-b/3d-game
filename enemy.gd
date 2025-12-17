extends CharacterBody3D

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var attack_area: Area3D = get_node_or_null("AttackArea")
@onready var attack_cd: Timer = get_node_or_null("AttackCooldown")

@export var speed: float = 3.0
@export var roam_radius: float = 10.0

@export var max_health: int = 50
@export var contact_damage: int = 10
@export var attack_cooldown_time: float = 0.9

var health: int
var home_position: Vector3
var player: Node3D = null

func _ready() -> void:
	add_to_group("enemies")

	# --- Health ---
	health = max_health

	# --- Roam origin ---
	home_position = global_position
	pick_new_destination()

	# --- Attack system nodes sanity checks ---
	if attack_area == null:
		push_error("Enemy is missing child node 'AttackArea' (Area3D).")
	else:
		attack_area.body_entered.connect(_on_attack_body_entered)
		attack_area.body_exited.connect(_on_attack_body_exited)

	if attack_cd == null:
		push_error("Enemy is missing child node 'AttackCooldown' (Timer).")
	else:
		attack_cd.one_shot = true
		attack_cd.wait_time = attack_cooldown_time
		attack_cd.timeout.connect(_try_attack)

func set_player(p: Node3D) -> void:
	player = p

func _physics_process(delta: float) -> void:
	# Decide target: chase player if known; else roam
	if player and is_instance_valid(player):
		nav_agent.target_position = player.global_position
	elif nav_agent.is_target_reached():
		pick_new_destination()

	# Move along path
	var next_pos: Vector3 = nav_agent.get_next_path_position()
	var dir := next_pos - global_position
	dir.y = 0.0

	if dir.length() > 0.1:
		velocity = dir.normalized() * speed
	else:
		velocity = Vector3.ZERO

	move_and_slide()

func pick_new_destination() -> void:
	var offset := Vector3(
		randf_range(-roam_radius, roam_radius),
		0.0,
		randf_range(-roam_radius, roam_radius)
	)
	nav_agent.target_position = home_position + offset

# -------------------------
# Damage receiver (from HurtBox.gd calling take_damage on this node)
# -------------------------
func take_damage(amount: int) -> void:
	health = max(health - amount, 0)
	print("%s took %d damage. HP=%d" % [name, amount, health])

	# Optional: flash or reaction could go here

	if health == 0:
		die()

func die() -> void:
	print("%s died" % name)
	queue_free()

# -------------------------
# Attacking player (AttackArea)
# -------------------------
func _on_attack_body_entered(body: Node) -> void:
	# Player enters range
	if body.has_method("take_damage"):
		player = body as Node3D
		_try_attack()

func _on_attack_body_exited(body: Node) -> void:
	if player and body == player:
		player = null

func _try_attack() -> void:
	if player == null or not is_instance_valid(player):
		return
	if attack_cd == null:
		return

	# Only hit if cooldown is ready
	if attack_cd.is_stopped():
		player.take_damage(contact_damage)
		print("%s hit player for %d" % [name, contact_damage])
		attack_cd.start()
