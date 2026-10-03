extends CharacterBody3D


const SPEED = 300
const JUMP_VELOCITY = 4.5
const SPEED_ROTATE = 15

@onready var start_pos = position
@export var path_length = 10

@onready var start_angle = rotation.y
var is_rotate = false
var current_angle = 0

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	var direction := (transform.basis * Vector3.FORWARD).normalized()
	if start_pos.distance_to(position) >= path_length / 2:
		direction = Vector3.ZERO
		is_rotate = true
		
	if is_rotate == true:
		var angle = SPEED_ROTATE * delta
		rotate_y(angle)
		current_angle += angle
		
		if current_angle >= PI:
			is_rotate = false
			current_angle = 0
			# Вирівнювання персонажа щоб позбавитись похибки
			rotation.y = start_angle + PI
			start_angle = rotation.y
			# Робимо крок, щоб в новому напряку, щоб вийты за межі д
			direction = (transform.basis * Vector3.FORWARD).normalized()
		
	if direction:
		velocity.x = direction.x * SPEED * delta
		velocity.z = direction.z * SPEED * delta
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
