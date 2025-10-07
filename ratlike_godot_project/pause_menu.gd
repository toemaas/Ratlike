# pause_menu.gd
extends Control

func _on_resume_pressed() -> void:
	get_parent().toggle_pause()

func _on_quit_pressed() -> void:
	get_tree().quit()

func _unhandled_input(event):
	if event.is_action_pressed("ui_pause"):
		get_tree().root.set_input_as_handled()
		get_parent().toggle_pause()
