extends Area3D

func _on_body_entered(body):
	print("CHEESE TOUCH")
	queue_free()
	return
