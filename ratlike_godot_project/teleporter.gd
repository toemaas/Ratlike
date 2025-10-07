extends Area3D

"""
	Generic Teleporter script
	
	Makes use of a Singleton, SceneManager, which is scripted in scene_manager.gd
	
	IMPORTANT:
		Whenever a teleporter scene is instantiated, the scene must have an @onready
		loading script in the main node.
		
		Example:
			SceneManger.next_scene = preload("<valid .tscn path>")
		
		inside _ready of the script.
	
	@param needed_cheese	custom amount of cheese which can be set in Inspector
"""

@export var needed_cheese: int = 0
@onready var scene_manager = SceneManager

func _on_body_entered(body):
	if body.get_cheese_count() < needed_cheese:
		print("DEBUG: Not enough cheese")
		$DialogueBox.start()
		return
	
	if scene_manager.next_scene:
		scene_manager.transition_to_scene(scene_manager.next_scene)
		print("DEBUG: Transitioned to next scene")
	else:
		print("DEBUG: next_scene is null")
