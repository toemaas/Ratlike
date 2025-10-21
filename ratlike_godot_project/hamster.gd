extends CharacterBody3D

signal squashed(cheese)

@export var patrol_points: Array[Vector3]
@export var movement_speed: float = 25.0

@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D

var cheese = false # cheese flag, true if cheese is stolen

# This will keep track of which point we are moving towards.
var current_patrol_index: int = 0

func _ready():
	navigation_agent.path_desired_distance = 0.5
	navigation_agent.target_desired_distance = 1.0
	actor_setup.call_deferred()

func actor_setup():
	await get_tree().physics_frame
	
	# Make sure we have points to move to.
	if patrol_points.is_empty():
		return

	# Set the first movement target.
	set_movement_target(patrol_points[current_patrol_index])

func set_movement_target(movement_target: Vector3):
	navigation_agent.set_target_position(movement_target)

func _physics_process(delta):
	if patrol_points.is_empty():
		return

	# Check if we've arrived at the target.
	if navigation_agent.is_navigation_finished():
		# Move to the next point in the array.
		current_patrol_index = (current_patrol_index + 1) % patrol_points.size()
		
		set_movement_target(patrol_points[current_patrol_index])

		return

	# Standard movement code from before.
	var current_agent_position: Vector3 = global_position
	var next_path_position: Vector3 = navigation_agent.get_next_path_position()

	velocity = current_agent_position.direction_to(next_path_position) * movement_speed
	$Pivot.look_at(global_position + velocity, Vector3.UP)
	move_and_slide()

func squash():
	squashed.emit(cheese)
	print("HAMSTER SQUASHED")
	queue_free()

func steal_cheese():
	cheese = true
	$Cheese.visible = true
	$Label3D.visible = true
	await get_tree().create_timer(2.0).timeout
	$Label3D.visible = false

#HELPER
func getCheese():
	return cheese
