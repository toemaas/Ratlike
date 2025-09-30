extends Node

@export var current_level: String = ""
@export var next_scene: PackedScene = null

func transition_to_scene(new_scene: PackedScene):
	if new_scene:
		var str = str(get_tree().change_scene_to_packed(new_scene))
		print("DEBUG: " + str)
		current_level = new_scene.resource_path
	else:
		print("DEBUG: Trying to load a null scene")
