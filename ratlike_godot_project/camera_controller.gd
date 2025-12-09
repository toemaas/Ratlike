extends Node3D

signal set_cam_rotation(_cam_rotation : float)

@onready var yaw_node = $CamYaw
@onready var pitch_node = $CamYaw/CamPitch
@onready var spring_arm = $CamYaw/CamPitch/SpringArm3D
@onready var camera = $CamYaw/CamPitch/SpringArm3D/Camera3D

var min_zoom : float = 2.0
var max_zoom : float = 10.0 
var zoom_speed : float = 1.0 
var zoom_smoothing : float = 10.0

var target_zoom : float = 0.0

var yaw : float = 0
var pitch : float = 0

var modifier = 4

var yaw_sensitivity : float = 0.07 * modifier
var pitch_sensitivity : float = 0.07 * modifier

var yaw_acceleration : float = 15 * modifier
var pitch_acceleration : float = 15 * modifier

var pitch_max : float = 75
var pitch_min : float = -55

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	target_zoom = spring_arm.position.z

func _input(event):
	if event is InputEventMouseMotion:
		yaw += -event.relative.x * yaw_sensitivity
		pitch += event.relative.y * pitch_sensitivity
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			target_zoom -= zoom_speed
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			target_zoom += zoom_speed
		target_zoom = clamp(target_zoom, min_zoom, max_zoom)
	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
func _physics_process(delta):
	pitch = clamp(pitch, pitch_min, pitch_max)
	
	# this is for smooth camera rotation
	#yaw_node.rotation_degrees.y = lerp(yaw_node.rotation_degrees.y, yaw, yaw_acceleration * delta)
	#pitch_node.rotation_degrees.x = lerp(pitch_node.rotation_degrees.x, pitch, pitch_acceleration * delta)
	
	# Fast camera rotation
	yaw_node.rotation_degrees.y = yaw
	pitch_node.rotation_degrees.x = -pitch
	
	spring_arm.spring_length = lerp(spring_arm.spring_length, target_zoom, zoom_smoothing * delta)
	
	set_cam_rotation.emit(yaw_node.rotation.y)
