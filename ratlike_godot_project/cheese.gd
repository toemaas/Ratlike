extends Area3D

signal cheese_collected

@onready var sound = $AudioStreamPlayer3D

func _on_body_entered(body):
	cheese_collected.emit()
	sound.play()
	$"Cheese Wheel".visible = false


func _on_audio_stream_player_3d_finished() -> void:
	print("CHEESE TOUCH")
	queue_free()
