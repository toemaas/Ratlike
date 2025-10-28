extends Control

@onready var texture_rect = $TextureRect
var images = [
	preload("res://TutorialScreen/RatlikeTutorialScreen1.jpg"),
	preload("res://TutorialScreen/RatlikeTutorialScreen2.jpg"),
	preload("res://TutorialScreen/RatlikeTutorialScreen3.jpg")
]

var current_index = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	texture_rect.texture = images[current_index]
	texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	texture_rect.expand = true
	texture_rect.anchor_left = 0.0
	texture_rect.anchor_top = 0.0
	texture_rect.anchor_right = 1.0
	texture_rect.anchor_bottom = 1.0
	texture_rect.offset_left = 0
	texture_rect.offset_top = 0
	texture_rect.offset_right = 0
	texture_rect.offset_bottom = 0
	pass # Replace with function body.


func _input(event):
	if event.is_action_pressed("ui_accept"):  # Default mapped to Space/Enter
		change_image()
		

func change_image():
	if current_index == 2:
		get_tree().change_scene_to_file("res://level_one.tscn")
	
	
	current_index = (current_index + 1) % images.size()
	texture_rect.texture = images[current_index]
	
