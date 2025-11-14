extends Area3D

signal powerup_obtained

@onready var sound = $AudioStreamPlayer3D

func _on_body_entered(_body):
	if not $Skin.visible:
		return
	
	emit_signal("powerup_obtained")
	sound.play()
	$Skin.visible = false

func _on_audio_stream_player_3d_finished() -> void:
	queue_free()

func _physics_process(_delta: float) -> void:
	# rotates powerup by 0.1 radians every frame
	rotate_y(0.1)
