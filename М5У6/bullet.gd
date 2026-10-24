extends RigidBody3D

var speed = 30
var life_time = 2
# Урон, що наносить звичайна куля
var damage_amount = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	apply_central_impulse(transform.basis * Vector3(0, 0, -speed))
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	life_time -= delta
	if life_time <= 0:
		queue_free()
		
	var bodies = get_colliding_bodies()
	for body in bodies:
		if body.is_in_group('enemy'):
			body.damage(damage_amount)
		queue_free()
	
