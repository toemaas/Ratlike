extends Area3D

signal cheese_collected

@onready var sound = $AudioStreamPlayer3D

func _on_body_entered(body):
	sound.play()
	$"Cheese Wheel".visible = false


func _on_audio_stream_player_3d_finished() -> void:
	print("CHEESE TOUCH")
	emit_signal("cheese_collected")
	queue_free()
