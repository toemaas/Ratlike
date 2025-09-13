extends CharacterBody3D

# How fast the player moves in m/s
@export var speed = 14
# The downward accel when in the air, in m/s^2
@export var fall_acceleration = 75
# jump intensity
@export var jump_impulse = 20
# jump limit
@export var max_jumps = 2
# consecutive jump intensity
var consec_jump_impulse = jump_impulse / 2
# rolling speed
@export var roll_strength = 150
# roll length
@export var roll_duration = 0.5
# roll gravity
var roll_gravity = fall_acceleration * 0.3

# jump count
var jumped = 0
# rolling flag, default false
var rolling = false
# roll direction
var roll_direction = Vector3.ZERO

@onready
var animation_player = $Pivot/RatModelDraft1Brown/AnimationPlayer

var target_velocity = Vector3.ZERO

func _physics_process(delta):
	# We create a local variable to store the input direction.
	var direction = Vector3.ZERO
	
	# check for roll input
	if Input.is_action_just_pressed("roll") and not rolling:
		roll()
	
	# We check for each move input and update the direction accordingly
	if rolling:
		var y_val = velocity.y
		velocity = roll_direction * roll_strength * $RollCooldown.time_left
		velocity.y = -abs(y_val)
		if not is_on_floor():
			velocity.y = velocity.y - (roll_gravity * delta)
	else:
		if Input.is_action_pressed("move_right"):
			direction.x += 1
		if Input.is_action_pressed("move_left"):
			direction.x -= 1
		if Input.is_action_pressed("move_back"):
			direction.z += 1
		if Input.is_action_pressed("move_forward"):
			direction.z -= 1
	
	# normalization
	if direction != Vector3.ZERO:
		direction = direction.normalized()
		#$Pivot.look_at(global_transform.origin + direction, Vector3.UP)
		$Pivot.basis = Basis.looking_at(direction)

	else:
		animation_player.stop()
	
	# Vertical velocity
	if not is_on_floor(): # If in the air, fall towards floor.
		target_velocity.y = target_velocity.y - (fall_acceleration * delta)
	
	# Ground velocity
	if not rolling:
		target_velocity.x = (direction.x * speed) + (roll_strength * $RollCooldown.time_left)
		target_velocity.z = (direction.z * speed) + (roll_strength * $RollCooldown.time_left)
		# move
		velocity = target_velocity
		animation_player.play("WalkCycle")
	
	#if is_on_floor() and Input.is_action_just_pressed("jump"):
		#target_velocity.y = jump_impulse
	
	if max_jumps > 1 and Input.is_action_just_pressed("jump"):
		if jumped == 0:
			target_velocity.y = jump_impulse
		else:
			target_velocity.y = consec_jump_impulse
		jumped += 1
		max_jumps -= 1
	
	move_and_slide()
	
	if is_on_floor():
		max_jumps += jumped
		jumped = 0

func _on_roll_cooldown_timeout():
	rolling = false
	velocity = Vector3.ZERO

func roll():
	if $RollCooldown.time_left != 0:
		$RollCooldown.stop()
		_on_roll_cooldown_timeout()
		return
	$RollCooldown.start(roll_duration)
	rolling = true
	roll_direction = -$Pivot.transform.basis.z.normalized()
