# main.gd
extends Node3D

@onready var pause_menu = $PauseMenu
@onready var charge_bar = $TextureProgressBar
@onready var choice_menu = $PowerUpChoice

var choice = false

func _ready() -> void:
	pause_menu.hide()
	SceneManager.next_scene = preload("res://level2.tscn")

func _unhandled_input(event):
	print("choice flag is " + str(choice))
	if choice: # doesnt stop the game from unpausing while choice hasn't been made
		return
	if event.is_action_pressed("ui_pause"):
		get_tree().root.set_input_as_handled()
		toggle_pause()

func toggle_pause():
	get_tree().paused = not get_tree().paused
	if get_tree().paused:
		pause_menu.show()
	else:
		pause_menu.hide()
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func toggle_choice():
	choice = not choice
	#await get_tree().create_timer(1.0).timeout4
	print("DEBUG: choice got set to " + str(choice))
	get_tree().paused = not get_tree().paused
	if get_tree().paused:
		choice_menu.show()
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		choice_menu.hide()
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func update_jump_charge(charge_value):
	charge_bar.value = charge_value	
