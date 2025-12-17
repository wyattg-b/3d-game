extends CanvasLayer

@onready var health_bar: Range = $Control/HealthBar

func connect_to_player(player: Node) -> void:
	player.health_changed.connect(_on_health_changed)
	player.died.connect(_on_died)

	# IMPORTANT: player already emitted in _ready(), so initialize manually now
	if player.has_method("get_health_data"):
		var data: Array = player.get_health_data()
		_on_health_changed(data[0], data[1])

func _on_health_changed(current: int, maxhp: int) -> void:
	health_bar.max_value = maxhp
	health_bar.value = current

func _on_died() -> void:
	print("GAME OVER")
