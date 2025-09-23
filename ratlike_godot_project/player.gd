extends CharacterBody3D

"""
	Player script.
	
	This script houses the logic for our player which includes signal handling,
	movement, and animation.
	
	Exported variables are variables which can be modified in the 'Inspector'
	window on the right hand side when viewing a Player node in the 3D scene.
	
	Any variable which is not exported is not meant to be modified outside of
	'Inspector' window.
	
	Player movement controls:
		Walk: W A S D
		Roll: R
		Cancel Roll: R
		Jump: SPACE
			Can be done multiple times if var max_jumps is changed
"""

# ---------------- EXPORTED GLOBAL VARIABLES (DEFAULTS)
@export var speed = 14
@export var fall_acceleration = 75
@export var jump_impulse = 20
@export var max_jumps = 2
@export var roll_strength = 150
@export var roll_duration = 0.5
@export var bounce_impulse = 16
@export var hit_impulse = 50
# ---------------- GLOBAL VARIABLES
var cheese_count = 0 # cheese...
var cam_rotation : float = 0 # camera yaw rotation amount
var consec_jump_impulse = jump_impulse / 2 # lowers jump intensity after initial jump
var roll_gravity = fall_acceleration * 0.3 # lowers gravity during roll
var jumped = 0 # counts how many times player has jumped
var rolling = false # flag for when player is actively rolling
var roll_direction = Vector3.ZERO # maintain direction when rolling
var knockback = Vector3.ZERO # If there is knockback
@onready # animation_player must be set when Player is first created
var animation_player = $Pivot/RatModelDraft1Brown/AnimationPlayer
var target_velocity = Vector3.ZERO

"""
	_physics_process is called every frame while the node is in the active
	scene tree. If the node is not in the scene tree, this function will
	not be called.
	
	@param delta	used to synchronize physics frames by maintaining the 
					relative time between frames
"""
func _physics_process(delta):	
	# ---------------- MOVEMENT INPUT
	if Input.is_action_just_pressed("roll"):
		roll()
	
	var input_dir = Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_back") - Input.get_action_strength("move_forward")
	)
	
	var direction = Vector3.ZERO
	# ---------------- APPLYING MOVEMENT
	if input_dir.length_squared() > 0: # player is moving
		input_dir = input_dir.normalized()
		
		# Rotate the input vector by the camera's horizontal rotation
		direction = Vector3(input_dir.x, 0.0, input_dir.y).rotated(Vector3.UP, cam_rotation)
		
		# Rotate the player model to face the direction of movement
		$Pivot.look_at(global_position + direction, Vector3.UP)
		animation_player.play("WalkCycle")
	else: # player is idle
		animation_player.stop()
	
	# apply gravity if in air
	if not is_on_floor() and not rolling:
		target_velocity.y = target_velocity.y - (fall_acceleration * delta)
	elif not is_on_floor() and rolling:
		velocity.y -= roll_gravity * delta

	# set player movement (node velocity vector)
	if not rolling: # player is walking
		target_velocity.x = (direction.x * speed)
		target_velocity.z = (direction.z * speed)
		velocity = target_velocity
	else: # player is rolling
		# roll has adjusted gravity, first capture y vector and then update velocity
		var y_val = velocity.y
		velocity = roll_direction * roll_strength * $RollCooldown.time_left
		velocity.y = -abs(y_val)
	
	"""
		Jump logic is a little weird. The variables max_jumps and jumped are
		acting as counters and the jump impulse is different depending on their
		states.
		
		Whenever we jump we add 1 to jumped and then remove 1 from max_jumps.
		These counters get updated every frame in the last if function of
		_physics_process(...).
	"""
	if max_jumps > 1 and Input.is_action_just_pressed("jump") and not rolling:
		if jumped == 0:
			target_velocity.y = jump_impulse
		else:
			target_velocity.y = consec_jump_impulse
		jumped += 1
		max_jumps -= 1
	
	
	# update global variables
	if is_on_floor():
		max_jumps += jumped
		jumped = 0
		
	for index in range(get_slide_collision_count()):
		var collision = get_slide_collision(index)
		
		if collision.get_collider() == null:
			continue
		
		if collision.get_collider().is_in_group("mob"):
			var mob = collision.get_collider()
			# we check that we are hitting it from above.
			if Vector3.UP.dot(collision.get_normal()) > 0.1:
				# If so, we squash it and bounce.
				mob.squash()
				target_velocity.y = bounce_impulse
				# Prevent further duplicate calls.
				break
			else:
				var bounce_direction = collision.get_normal().slide(Vector3.UP).normalized()
				knockback.x = bounce_direction.x * hit_impulse
				knockback.z = bounce_direction.z * hit_impulse
				break
	velocity += knockback
	knockback = lerp(knockback, Vector3.ZERO, 0.2)
	# finish process and move player node
	move_and_slide()
"""
	When RollCooldown times out, the timeout signal is sent to this
	function and lowers the flag for rolling and resets the velocity
	vector to 0.
"""
func _on_roll_cooldown_timeout():
	rolling = false
	velocity = Vector3.ZERO

"""
	roll() handles the logic for rolling and raises the rolling flag.
	
	The logic here is using a Timer node to create a smooth roll and
	temporarily lock movement in place.
	
	Extra feature—roll cancellation. If roll is activated while roll
	is already active, it will stop rolling instantly.
	
	TODO: change roll cancellation to jump input and not roll input
"""
func roll():
	if $RollCooldown.time_left != 0:
		$RollCooldown.stop()
		_on_roll_cooldown_timeout()
		print("roll cancelled")
		return
	$RollCooldown.start(roll_duration)
	rolling = true
	roll_direction = -$Pivot.transform.basis.z.normalized()

func _on_cam_root_set_cam_rotation(_cam_rotation: float):
	cam_rotation = _cam_rotation

# This function is called when a cheese is collected
func collect_cheese():
	print("collect cheese called")
	cheese_count += 1
	update_ui()

# This function is called when a mob is squashed
func squashed():
	print("squashed called")

# This function updates the text on the UI label
func update_ui():
	print("update ui called")
	if get_node("Hud/Label") != null:
		get_node("Hud/Label").text = "Cheese: " + str(cheese_count)


func get_cheese_count():
	return cheese_count
	if get_node("Hud/CheeseLabel") != null:
		get_node("Hud/CheeseLabel").text = "Cheese: " + str(cheese_count)
