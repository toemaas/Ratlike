extends Area3D

@export var next_scene: PackedScene = null

func _on_body_entered(body):
	print("Teleporter does not work")
	if next_scene:
		get_tree().change_scene_to_packed(next_scene)
	else:
		print("scene is null")
