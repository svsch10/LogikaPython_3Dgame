extends RigidBody3D

var speed = 30
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	apply_central_impulse(transform.basis * Vector3(0, 0, -speed))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
