extends CharacterBody3D

"""
	Player script.
	
	This script houses the logic for our player which includes signal handling,
	movement, and animation.
	
	Exported variables are variables which can be modified in the 'Inspector'
	window on the right hand side when viewing a Player node in the 3D scene.
	
	Any variable which is not exported is not meant to be modified outside of
	'Inspector' window.
"""

# ---------------- EXPORTED GLOBAL VARIABLES (DEFAULTS)
@export var speed = 14
@export var fall_acceleration = 75
@export var jump_impulse = 20
@export var max_jumps = 2
@export var roll_strength = 150
@export var roll_duration = 0.5

# ---------------- GLOBAL VARIABLES
var consec_jump_impulse = jump_impulse / 2 # lowers jump intensity after initial jump
var roll_gravity = fall_acceleration * 0.3 # lowers gravity during roll
var jumped = 0 # counts how many times player has jumped
var rolling = false # flag for when player is actively rolling
var roll_direction = Vector3.ZERO # maintain direction when rolling
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
	var direction = Vector3.ZERO
	
	if Input.is_action_just_pressed("roll"):
		roll()
	if Input.is_action_pressed("move_right"):
		direction.x += 1
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	if Input.is_action_pressed("move_back"):
		direction.z += 1
	if Input.is_action_pressed("move_forward"):
		direction.z -= 1
	
	# ---------------- APPLYING MOVEMENT
	if direction != Vector3.ZERO and not rolling: # player is moving
		direction = direction.normalized()
		$Pivot.basis = Basis.looking_at(direction)
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
	
	# finish process and move player node
	move_and_slide()
	
	# update global variables
	if is_on_floor():
		max_jumps += jumped
		jumped = 0

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
