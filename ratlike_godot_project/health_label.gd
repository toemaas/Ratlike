# HealthBar.gd
extends RichTextLabel

var current_health: int = 3
const HEART = "❤️"

# Redraws the hearts based on the current_health value
func update_display():
	var new_text = ""
	for i in range(current_health):
		new_text += HEART
	self.text = new_text

# This is the function you will call from your player script
func take_damage(amount: int):
	current_health -= amount
	current_health = max(0, current_health) # Prevents health from going below 0
	update_display()

# You might want a function to set the initial state too
func set_health(health_value: int):
	current_health = health_value
	update_display()
