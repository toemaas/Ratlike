extends CharacterBody3D

signal squashed

func squash():
	squashed.emit()
	print("HAMSTER SQUASHED")
	queue_free()
