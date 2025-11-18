extends Control

signal powerup_chosen


func _on_powerup_powerup_obtained() -> void:
	get_parent().toggle_choice()
	emit_signal("powerup_chosen")


func _on_speed_button_pressed() -> void:
	print("speed pressed")
	if not PowerupLogic.speed:
		PowerupLogic.speed = true
	 
	get_parent().toggle_choice()
	emit_signal("powerup_chosen")
	$BoxContainer/SpeedButton.visible = false


func _on_charge_height_button_pressed() -> void:
	print("height pressed")
	if not PowerupLogic.height:
		PowerupLogic.height = true
	
	get_parent().toggle_choice()
	emit_signal("powerup_chosen")
	$BoxContainer2/ChargeHeightButton.visible = false
