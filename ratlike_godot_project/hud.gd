extends Control

@onready var charge_bar = $CanvasLayer/ChargeBar

func _on_player_jump_charge_changed(charge_value):
	if charge_value == 0.0:
		charge_bar.visible = false
	else:
		charge_bar.visible = true
		charge_bar.value = charge_value
