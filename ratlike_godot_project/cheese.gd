extends Area3D

signal cheese_collected

func _on_body_entered(body):
	print("CHEESE TOUCH")
	emit_signal("cheese_collected")
	queue_free()
	return
