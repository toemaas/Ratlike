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

var timer = 0.0
var done = false

func _ready() -> void:
	$Camera3D.current = false
	
func _process(delta: float) -> void:
	if GlobalVars.d_active:
		if timer < 1.5:
			timer += delta
			#$RatMafia.transform.origin += Vector3(0, delta * 1, 0)
			$RatMafia.position.z += delta * 1;
	else:
		if timer > 0:
			timer -= delta
			#$RatMafia.transform.origin -= Vector3(0, delta * 1, 0)
			$RatMafia.position.z -= delta * 1;
	
	if done and GlobalVars.d_active == false:
		if scene_manager.next_scene:
			scene_manager.transition_to_scene(scene_manager.next_scene)
			print("DEBUG: Transitioned to next scene")
		else:
			get_tree().quit()
			print("DEBUG: next_scene is null")
			
func _on_body_entered(body):
	if body.get_cheese_count() < needed_cheese:
		$Camera3D.current = true
		print("DEBUG: Not enough cheese")
		$DialogueBox.start(true)
		return
	else:
		$Camera3D.current = true
		print("DEBUG: Not enough cheese")
		done = true
		$DialogueBox.start(false)
		return
