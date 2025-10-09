extends Button

# Path to the scene you want to load
@export var next_scene_path: String = "res://level_one.tscn"

func _ready() -> void:
	# Connect the "pressed" signal to the _on_button_pressed function
	pressed.connect(_on_button_pressed)

func _on_button_pressed() -> void:
	# Change to the new scene
	get_tree().change_scene_to_file(next_scene_path)
	
