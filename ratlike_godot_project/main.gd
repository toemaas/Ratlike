# main.gd
extends Node3D

@onready var pause_menu = $PauseMenu

func _ready() -> void:
	pause_menu.hide()
	SceneManager.next_scene = preload("res://testing_grounds.tscn")

func _unhandled_input(event):
	if event.is_action_pressed("ui_pause"):
		get_tree().root.set_input_as_handled()
		toggle_pause() # Call the new function

func toggle_pause():
	get_tree().paused = not get_tree().paused
	if get_tree().paused:
		pause_menu.show()
	else:
		pause_menu.hide()
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
