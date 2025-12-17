extends Node3D 

var health: int = 100
var max_health: int = 100

func take_damage(amount: int):
	health -= amount
	print(name, " took ", amount, " damage. Health: ", health)
	if health <= 0:
		die()

func die():
	print(name, " died!")
	# Add death animations, sound effects, or scene transitions here
	queue_free() # Removes the entity from the game
