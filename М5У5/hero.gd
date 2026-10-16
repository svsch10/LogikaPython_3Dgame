extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

@onready var anim_player = $hero/AnimationPlayer

@onready var bullet_gun = load("res://bullet.tscn")


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		anim_player.play("jump") 

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		
	# Анімація
	if is_on_floor() and anim_player.current_animation != "jump":
		if direction:
			anim_player.play("walk")
		else:
			anim_player.play("idle")

	print(anim_player.current_animation)

	move_and_slide()
	
	
func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("shoot"):
		var inst = bullet_gun.instantiate()
		inst.transform = %ray_gun.global_transform
		get_tree().current_scene.add_child(inst)
		
	if Input.is_key_pressed(KEY_D):
		rotate_y(0.1)	
