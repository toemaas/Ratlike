extends Node3D


"""
	Just a script to set this level's next scene without circular dependencies
"""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SceneManager.next_scene = preload("res://floor.tscn")
	print(str(SceneManager.current_level))
	pass
