extends Area3D

signal powerup_obtained

@onready var sound = $AudioStreamPlayer3D

func _on_body_entered(body):
	if not $Skin.visible:
		return
	
	# set power to be true if it isnt already
	if not PowerupLogic.power:
		PowerupLogic.power = true
	
	print("DEBUG: The power var is " + str(PowerupLogic.power))
	emit_signal("powerup_obtained")
	sound.play()
	$Skin.visible = false

func _on_audio_stream_player_3d_finished() -> void:
	print("DEBUG: POWERUP OBTAINED")
	queue_free()

func _physics_process(delta: float) -> void:
	# rotates powerup by 0.1 radians every frame
	rotate_y(0.1)
