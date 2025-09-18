extends Area3D

"""
	Generic Teleporter script
	
	This script in its default state is non-usable. When using this script on
	an object, you must set the parameters.
	
	@parma next_scene	Takes a .tscn file for the next scene to teleport to
	@param needed_cheese	Takes an integer for the minimum number of cheese
						required to teleport to the next level (scene)
"""

@export var next_scene: PackedScene = null
@export var needed_cheese = 0

func _on_body_entered(body):
	if body.get_cheese_count() < needed_cheese:
		print("DEBUG: Not enough cheese")
		return
	if next_scene:
		get_tree().change_scene_to_packed(next_scene)
	else:
		print("DEBUG: teleport scene is null")
