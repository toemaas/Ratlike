extends Area3D

signal powerup_obtained

@onready var sound = $AudioStreamPlayer3D

func _on_body_entered(_body):
	if not $Skin.visible:
		return
	
	# set power to be true if it isnt already
	#if not PowerupLogic.power:
		#PowerupLogic.power = true
	
	#if not PowerupLogic.size:
		#PowerupLogic.size = true
	
	if not PowerupLogic.speed:
		PowerupLogic.speed = true
	
	if not PowerupLogic.rollSpeed:
		PowerupLogic.rollSpeed = true
	
	if not PowerupLogic.extraJump:
		PowerupLogic.extraJump = true
	
	emit_signal("powerup_obtained")
	sound.play()
	$Skin.visible = false

func _on_audio_stream_player_3d_finished() -> void:
	queue_free()

func _physics_process(_delta: float) -> void:
	# rotates powerup by 0.1 radians every frame
	rotate_y(0.1)
