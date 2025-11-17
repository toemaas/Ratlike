extends CharacterBody3D

@export var patrol_points: Array[Vector3]
@export var movement_speed: float = 15.0

@export var jump_speed = 20.0
@export var jump_strength = 20.0
@export var lunge_speed = 50.0
@export var lunge_duration = 0.5
@export var windup_duration = 0.5
@export var hit_duration = 2
@export var cooldown_duration = 1.0

@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
@onready var sight_area = $SightArea

@onready var animation_player = $Pivot/'Hamster All Animations'/AnimationPlayer
@onready var skeleton: PhysicalBoneSimulator3D = $"Pivot/Temp Hamster/metarig/Skeleton3D/PhysicalBoneSimulator3D"
@export var gravity_multiplier = 2.5

var current_patrol_index: int = 0

enum State {IDLE, WINDUP, LUNGE, COOLDOWN, HIT, JUMP_ATTACK}
var current_state = State.IDLE
var player_target = null
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var state_timer = 0.0
var attack_direction = Vector3.ZERO
var has_ball = 1
var attack_type = 0
var jump_horizontal_velocity = Vector3.ZERO

func _ready():
	navigation_agent.path_desired_distance = 0.5
	navigation_agent.target_desired_distance = 1.0
	actor_setup.call_deferred()

func actor_setup():
	await get_tree().physics_frame
	if patrol_points.is_empty():
		return
	set_movement_target(patrol_points[current_patrol_index])

func set_movement_target(movement_target: Vector3):
	navigation_agent.set_target_position(movement_target)

func _play_anim_safe(anim_name: String, speed: float = 1.0):
	if animation_player.has_animation(anim_name):
		if animation_player.current_animation != anim_name:
			animation_player.play(anim_name, -1, speed)
	else:
		print_debug("Animation not found: " + anim_name) 

func _physics_process(delta):
	match current_state:
		State.IDLE:
			_idle_state()
		State.WINDUP:
			_windup_state(delta)
		State.LUNGE:
			_lunge_state(delta)
		State.COOLDOWN:
			_cooldown_state(delta)
		State.HIT:
			_hit_state(delta)
		State.JUMP_ATTACK:
			_jump_attack_state(delta)

func _idle_state():
	if patrol_points.is_empty():
		#_play_anim_safe("Idle")
		return

	if navigation_agent.is_navigation_finished():
		# _play_anim_safe("Idle") 
		
		current_patrol_index = (current_patrol_index + 1) % patrol_points.size()
		set_movement_target(patrol_points[current_patrol_index])
		return

	# Standard movement code
	var current_agent_position: Vector3 = global_position
	var next_path_position: Vector3 = navigation_agent.get_next_path_position()

	velocity = current_agent_position.direction_to(next_path_position) * movement_speed
	
	_play_anim_safe("Ball Walk") 
	
	$Pivot.look_at(global_position + velocity, Vector3.UP)
	move_and_slide()
	
func _windup_state(delta):
	velocity = Vector3.ZERO
	move_and_slide()
	
	if attack_type > 0.5:
		_play_anim_safe("Ball Charging Up")
	else:
		_play_anim_safe("Ball Charging Jump")
	
	if player_target:
		$Pivot.look_at(player_target.global_position, Vector3.UP)
		
	state_timer -= delta
	if state_timer <= 0:
		if attack_type > 0.5: # randf() 0.0 - 1.0
			current_state = State.LUNGE
			state_timer = lunge_duration
			
			if player_target:
				attack_direction = (player_target.global_position - global_position).normalized()
			else:
				attack_direction = -$Pivot.global_transform.basis.z.normalized()
			attack_direction.y = 0
		# jump attack
		else:
			current_state = State.JUMP_ATTACK
			
			if not player_target:
				current_state = State.IDLE
				return
			
			var horizontal_vec = (player_target.global_position - global_position)
			horizontal_vec.y = 0
			var distance = horizontal_vec.length()
			
			if distance > 0:
				attack_direction = horizontal_vec.normalized()
			else:
				attack_direction = -$Pivot.global_transform.basis.z.normalized()
			
			var effective_gravity = gravity * gravity_multiplier
			if effective_gravity == 0:
				return
				
			var time_in_air = (2.0 * jump_speed) / effective_gravity
			if time_in_air == 0:
				return
				
			var calculated_horizontal_speed = distance / time_in_air
			
			var final_horizontal_speed = min(calculated_horizontal_speed, jump_speed)
			jump_horizontal_velocity = attack_direction * final_horizontal_speed
			
			velocity.y = jump_speed
			velocity.z = jump_horizontal_velocity.z
			velocity.x = jump_horizontal_velocity.x
	
func _lunge_state(delta):
	velocity = lunge_speed * attack_direction
	move_and_slide()
	
	_play_anim_safe("Ball Charge")
	
	state_timer -= delta
	if state_timer <= 0:
		current_state = State.COOLDOWN
		state_timer = cooldown_duration
		velocity = Vector3.ZERO 

func _jump_attack_state(delta):
	velocity.y -= gravity * gravity_multiplier * delta
	
	move_and_slide()
	
	if velocity.y > 0:
		_play_anim_safe("Ball Jump")
	else:
		_play_anim_safe("Ball Stun")
	
	if is_on_floor():
		print("joefiajoiejfoiajeofi")
		current_state = State.COOLDOWN
		state_timer = cooldown_duration
		velocity = Vector3.ZERO

func _cooldown_state(delta):
	velocity = Vector3.ZERO
	move_and_slide()
	
	_play_anim_safe("Ball Stun")
	
	state_timer -= delta
	if state_timer <= 0:
		current_state = State.IDLE
		set_movement_target(patrol_points[current_patrol_index])

func _hit_state(delta):
	velocity = Vector3.ZERO
	move_and_slide()
	
	_play_anim_safe("Ball Break")
	
	state_timer -= delta
	if state_timer <= 0:
		if has_ball:
			$CollisionShape3D.disabled = true
			$"Pivot/Hamster All Animations/Ball1".visible = false
			has_ball = 0
		current_state = State.IDLE
		set_movement_target(patrol_points[current_patrol_index])

func _on_sight_area_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		player_target = body
		if current_state == State.IDLE:
			attack_type = randf()
			current_state = State.WINDUP
			state_timer = windup_duration
			navigation_agent.set_target_position(global_position)

func _on_sight_area_body_exited(body: Node3D) -> void:
	if body == player_target:
		player_target = null

func squished():
	print("HAMSTER SQUASHED")
	if has_ball:
		print("HAS BALL")
		current_state = State.HIT
		state_timer = hit_duration
	else:
		set_physics_process(false)
		_play_anim_safe("No Ball Stun")
		#$HamsterCollision.disabled = true
		#skeleton.physical_bones_start_simulation()
