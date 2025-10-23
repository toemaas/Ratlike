extends Area3D

signal powerup_obtained

func _on_body_entered(body):
	# set power to be true if it isnt already
	PowerupLogic.power = true if not PowerupLogic.power else false
	
	if not PowerupLogic.power:
		PowerupLogic.power = true
	
	print("DEBUG: The power var is " + str(PowerupLogic.power))
	emit_signal("powerup_obtained")
	queue_free()

func _physics_process(delta: float) -> void:
	# rotates powerup by 0.1 radians every frame
	rotate_y(0.1)
