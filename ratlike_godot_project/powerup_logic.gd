extends Node

"""
	Powerup singleton used for persistent data related to any power ups or
	other stat altering mechanics we want to add. Right now this is in a 
	proof of concept state and just has a barebones power variable which
	is handled in player.gd(update_powers) function whenever a powerup is
	obtained and when the player enters a new scene.
"""

@export var power: bool = false

@export var speed: bool = false
@export var size: bool = false
@export var rollSpeed: bool = false
@export var extraJump: bool = false
@export var height: bool = false
