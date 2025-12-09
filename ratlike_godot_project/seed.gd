extends Area3D

signal player_hit

@export var speed: float = 10.0
@export var damage: int = 1
var direction: Vector3 = Vector3.FORWARD

func _ready():
	await get_tree().create_timer(5.0).timeout
	queue_free()

func _physics_process(delta):
	position += direction * speed * delta

func _on_body_entered(body):
	if body.is_in_group("player"):
		print("Player hit!")
		if body.lose_cheese() > 0:
			player_hit.emit()
		queue_free()
	elif not body.is_in_group("boss"):
		queue_free()
