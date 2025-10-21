# HealthBar.gd
extends RichTextLabel

var current_health: int = 0
const HEART = "🧀"
# 🧀🧀🧀🧀🧀🧀🧀🧀🧀🧀🧀🧀🧀🧀🧀🧀🧀🧀🧀🧀🧀🧀
# Redraws the hearts based on the current_health value
func update_display():
	var new_text = ""
	for i in range(current_health):
		new_text += HEART
	self.text = new_text

# Cheese update
func update_dis(count):
	var new_text = ""
	for i in range(count):
		new_text += HEART
	self.text = new_text
	
#func take_damage(amount: int):
	#current_health -= amount
	#current_health = max(0, current_health) # Prevents health from going below 0
	#update_display()

#func set_health(health_value: int):
	#current_health = health_value
	#update_display()
