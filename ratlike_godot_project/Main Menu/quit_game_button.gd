extends Button

func _ready() -> void:
	# Connect the button's "pressed" signal to the function
	pressed.connect(_on_button_pressed)

func _on_button_pressed() -> void:
	# Quit the game
	get_tree().quit()
