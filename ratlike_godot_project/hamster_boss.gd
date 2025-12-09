extends CharacterBody3D

signal squashed(cheese)

@export var patrol_points: Array[Vector3]
@export var movement_speed: float = 15.0
@export var wander_radius: float = 10.0
@export var wander_center: Node3D

@export var jump_speed = 20.0
@export var jump_strength = 20.0
@export var lunge_speed = 50.0
@export var lunge_duration = 0.5
@export var jump_duration = 1.59
@export var windup_duration = 0.5
@export var hit_duration = 2
@export var cooldown_duration = 1.0
@export var projectile_scene: PackedScene
@export var projectile_speed: float = 90.0

@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
@onready var sight_area = $SightArea

@onready var animation_player = $Pivot/'Hamster All Animations'/AnimationPlayer
@onready var skeleton: PhysicalBoneSimulator3D = $"Pivot/Hamster All Animations/Armature/Skeleton3D/PhysicalBoneSimulator3D"
@export var gravity_multiplier = 2.5

@onready var squeak = $squeak
@onready var throwing_hit = $"Throwing Hit"
var cheese_count = 0
var cheese_lock = false

var current_patrol_index: int = 0
var is_waiting: bool = false

enum State {IDLE, WINDUP, LUNGE, COOLDOWN, HIT, JUMP_ATTACK, THROW}
var current_state = State.IDLE
var player_target = null
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var state_timer = 0.0
var attack_direction = Vector3.ZERO
var has_ball = 1
var attack_type = 0
var jump_horizontal_velocity = Vector3.ZERO

func _ready():
	$"Wander Timer".timeout.connect(_on_wander_timer_timeout)

func actor_setup():
	await get_tree().physics_frame
	
	if not patrol_points.is_empty():
		set_movement_target(patrol_points[current_patrol_index])
	else:
		current_state = State.IDLE

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
		State.THROW:
			_throw_state(delta)

func _idle_state():
	if navigation_agent.is_navigation_finished():
		if is_waiting:
			return
		
		is_waiting = true
		$"Wander Timer".start(0.25)
		return

	# Standard movement code
	var current_agent_position: Vector3 = global_position
	var next_path_position: Vector3 = navigation_agent.get_next_path_position()

	velocity = current_agent_position.direction_to(next_path_position) * movement_speed
	
	if has_ball:
		_play_anim_safe("Ball Walk")
	else:
		_play_anim_safe("No Ball Walk")
	
	$Pivot.look_at(global_position + velocity, Vector3.UP)
	move_and_slide()
	
func _windup_state(delta):
	velocity = Vector3.ZERO
	move_and_slide()
	
	if attack_type < 0.33:
		if has_ball:
			_play_anim_safe("Ball Charging Up")
		else:
			_play_anim_safe("No Ball Charge Up")
	else:
		if has_ball:
			_play_anim_safe("Ball Charging Jump")
		else:
			_play_anim_safe("No Ball Charging Jump")

	
	if player_target:
		$Pivot.look_at(player_target.global_position, Vector3.UP)
		
	state_timer -= delta
	if state_timer <= 0:
		# LUNGE ATTACK
		if attack_type < 0.33: # randf() 0.0 - 1.0
			current_state = State.LUNGE
			state_timer = lunge_duration
			
			if player_target:
				attack_direction = (player_target.global_position - global_position).normalized()
			else:
				attack_direction = -$Pivot.global_transform.basis.z.normalized()
			attack_direction.y = 0
		# JUMP ATTACK
		elif attack_type < 0.80:
			current_state = State.JUMP_ATTACK
			state_timer = jump_duration
			
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
		# THROWING ATTACK
		else:
			current_state = State.THROW
			state_timer = 1.0
			
	
func _lunge_state(delta):
	print("CALLING lunge ATTACK")
	velocity = lunge_speed * attack_direction
	move_and_slide()
	
	if has_ball:
		_play_anim_safe("Ball Charge")
	else:
		_play_anim_safe("No Ball Charge")
	
	state_timer -= delta
	if state_timer <= 0:
		current_state = State.COOLDOWN
		state_timer = cooldown_duration
		velocity = Vector3.ZERO 

func _jump_attack_state(delta):	
	print("CALLING JUMP ATTACK")
	velocity.y -= gravity * gravity_multiplier * delta
	
	move_and_slide()
	
	if velocity.y > 0:
		if has_ball:
			_play_anim_safe("Ball Jump")
		else:
			_play_anim_safe("No Ball Jump")
	else:
		if has_ball:
			_play_anim_safe("Ball Stun")
		else:
			_play_anim_safe("No Ball Stun")
	
	state_timer -= delta 
	if state_timer <= 0:
		current_state = State.COOLDOWN
		state_timer = cooldown_duration
		velocity = Vector3.ZERO
	#await get_tree().create_timer(1.59).timeout
		#
	#current_state = State.COOLDOWN
	#state_timer = cooldown_duration
	#velocity = Vector3.ZERO

func _cooldown_state(delta):
	velocity = Vector3.ZERO
	move_and_slide()
	
	if has_ball:
		_play_anim_safe("Ball Stun")
	else:
		_play_anim_safe("No Ball Stun")
	
	state_timer -= delta
	if state_timer <= 0:
		current_state = State.IDLE

func _hit_state(delta):
	print("HIT STATE")
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

func _throw_state(delta):
	velocity = Vector3.ZERO 
	move_and_slide()
	
	#_play_anim_safe("Throwing")
	
	if player_target:
		$Pivot.look_at(player_target.global_position, Vector3.UP)

	if state_timer > 0.5 and state_timer - delta <= 0.5:
		spawn_projectile()

	state_timer -= delta
	if state_timer <= 0:
		current_state = State.IDLE

func spawn_projectile():
	var new_projectile = projectile_scene.instantiate()
	new_projectile.player_hit.connect(_on_successful_hit)
	get_tree().current_scene.add_child(new_projectile)

	var spawn_pos = global_position + Vector3(0, 2, 0)
	
	new_projectile.global_position = spawn_pos
	var dir = Vector3.FORWARD
	
	var target_spot = player_target.global_position + Vector3(0, 0.5, 0)
	dir = spawn_pos.direction_to(target_spot)
	new_projectile.direction = dir
	new_projectile.speed = projectile_speed
	new_projectile.look_at(new_projectile.global_position + dir)

func _on_successful_hit():
	throwing_hit.play()
	steal_cheese()

func _on_sight_area_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		player_target = body
		if current_state == State.IDLE:
			attack_type = randf()
			current_state = State.WINDUP
			state_timer = windup_duration
			navigation_agent.set_target_position(global_position)

func _on_throw_area_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		player_target = body
		if current_state == State.IDLE:
			# throwing range
			attack_type = 0.81
			current_state = State.WINDUP
			state_timer = windup_duration
			navigation_agent.set_target_position(global_position)

func squished():
	print("HAMSTER SQUISHED")
	squeak.play()
	if has_ball:
		print("HAS BALL")
		current_state = State.HIT
		state_timer = hit_duration
	else:
		squash()
		set_physics_process(false)
		_play_anim_safe("No Ball Stun")
		$"Respawn Timer".start()
		#$HamsterCollision.disabled = true
		#skeleton.physical_bones_start_simulation()

func _on_timer_timeout() -> void:
	#$HamsterCollision.disabled = false
	$CollisionShape3D.disabled = false
	$"Pivot/Hamster All Animations/Ball1".visible = true
	has_ball = 1
	#skeleton.physical_bones_stop_simulation()
	animation_player.play_backwards("Ball Break")
	
func _on_animation_player_animation_finished(anim_name: String) -> void:
	if anim_name == "Ball Break":
		set_physics_process(true)
		current_state = State.IDLE

func squash():
	if cheese_lock or cheese_count == 0:
		return
		
	cheese_lock = true
	
	cheese_count -= 1
	squashed.emit(true)
	if cheese_count == 0:
		$Cheese.visible = false
		
	await get_tree().create_timer(0.25).timeout
	cheese_lock = false

func steal_cheese():
	throwing_hit.play()
	cheese_count += 1
	$Cheese.visible = true
	$Label3D.visible = true
	await get_tree().create_timer(2.0).timeout
	$Label3D.visible = false

func get_random_nav_point(center_pos: Vector3, radius: float) -> Vector3:
	var random_dir = Vector3(randf_range(-1, 1), 0, randf_range(-1, 1)).normalized()
	var random_dist = randf_range(0, radius)
	var target_pos = center_pos + (random_dir * random_dist)
	var map = get_world_3d().navigation_map
	return NavigationServer3D.map_get_closest_point(map, target_pos)

func _on_wander_timer_timeout():
	is_waiting = false
	
	# Patrol
	if not patrol_points.is_empty():
		var random_point = patrol_points.pick_random()
		set_movement_target(random_point)
	else:
		# Wander
		var new_target = get_random_nav_point(global_position, wander_radius)
		set_movement_target(new_target)
