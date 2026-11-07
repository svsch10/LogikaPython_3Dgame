extends RigidBody3D

@export var speed = 30
@export var life_time = 2.0
@export var damage_amount = 1

# Хто є ціллю кулі
@export var target_group = "enemy"

func _ready() -> void:
	apply_central_impulse(transform.basis * Vector3(0, 0, -speed))

func _physics_process(delta: float) -> void:
	life_time -= delta
	if life_time <= 0:
		queue_free()
		return
	
	var bodies = get_colliding_bodies()
	for body in bodies:
		if body.is_in_group(target_group):
			if body.has_method("damage"):
				body.damage(damage_amount)
			queue_free()
			return
