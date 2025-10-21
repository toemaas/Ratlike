extends TextureProgressBar


func _ready():
	# Get the player node (the parent of the CanvasLayer, which is the parent of this bar).
	# This path might change depending on your scene structure.
	var player = get_parent().get_parent().get_parent()
	
	# Connect this bar's 'update_charge' function to the player's signal.
	player.jump_charge_changed.connect(update_charge)

# This function will be called every time the player emits the signal.
func update_charge(charge_value):
	# Set the progress bar's value to the new charge amount.
	value = charge_value
