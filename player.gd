extends CharacterBody3D

@export var speed: float = 6.0
@export var gravity: float = 18.0
@export var jump_force: float = 6.0

@export var max_health: int = 100
var current_health: int

signal health_changed(current: int, maxhp: int)
signal died

@onready var fist: Area3D = get_node_or_null("fist") as Area3D
@onready var punch_timer: Timer = get_node_or_null("PunchTimer") as Timer

func _ready() -> void:
	current_health = max_health
	health_changed.emit(current_health, max_health)

	if fist == null:
		push_error("Player: Missing child node 'fist' (Area3D). Check name/case.")
	if punch_timer == null:
		push_error("Player: Missing child node 'PunchTimer' (Timer).")

	if punch_timer:
		punch_timer.one_shot = true
		punch_timer.timeout.connect(_on_punch_timer_timeout)

	# extra safety: ensure fist starts OFF
	if fist and fist.has_method("end_swing"):
		fist.end_swing()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("attack"):
		do_punch()

	if event.is_action_pressed("exit"):
		get_tree().quit()

func do_punch() -> void:
	if fist == null or punch_timer == null:
		return
	fist.start_swing()
	punch_timer.start(0.2)

func _on_punch_timer_timeout() -> void:
	if fist:
		fist.end_swing()

func _physics_process(delta: float) -> void:
	var input_dir := Vector3.ZERO

	if Input.is_action_pressed("move_forward"):
		input_dir -= transform.basis.z
	if Input.is_action_pressed("move_backward"):
		input_dir += transform.basis.z
	if Input.is_action_pressed("move_left"):
		input_dir -= transform.basis.x
	if Input.is_action_pressed("move_right"):
		input_dir += transform.basis.x

	input_dir = input_dir.normalized()

	velocity.x = input_dir.x * speed
	velocity.z = input_dir.z * speed

	if not is_on_floor():
		velocity.y -= gravity * delta
	elif Input.is_action_just_pressed("jump"):
		velocity.y = jump_force

	move_and_slide()

func take_damage(amount: int) -> void:
	if current_health <= 0:
		return
	current_health = max(current_health - amount, 0)
	health_changed.emit(current_health, max_health)
	if current_health == 0:
		die()

func die() -> void:
	print("Player died")
	died.emit()

# Used by HUD so it can initialize instantly even if signal already fired.
func get_health_data() -> Array:
	return [current_health, max_health]
