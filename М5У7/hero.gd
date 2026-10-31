extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const rotate_mouse_speed = 0.02

const gun_time_recharge = 0.5
var gun_recharge_timer = gun_time_recharge

const rifle_time_recharge = 2
var rifle_recharge_timer = rifle_time_recharge

# Зброя
@onready var gun = $hero/Armature/Skeleton3D/Bone_007/gun
@onready var rifle = $hero/Armature/Skeleton3D/Bone_007/rifle
var rifle_damage_amount = 3
@onready var weapons = [gun, rifle]
var current_weapon_index = 1

@onready var anim_player = $hero/AnimationPlayer

@onready var bullet_gun = load("res://bullet.tscn")

func _ready() -> void:
	# Початкове приховування зброї
	for ind in weapons.size():
		if current_weapon_index != ind:
			weapons[ind].visible = false
	
	
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
			
	gun_recharge_timer += delta
	rifle_recharge_timer += delta

	move_and_slide()
	
	
func _input(event: InputEvent) -> void:
	# Зміна зброї
	if Input.is_action_just_pressed("change_weapon"):
		weapons[current_weapon_index].visible = false
		current_weapon_index = (current_weapon_index + 1) % weapons.size()
		weapons[current_weapon_index].visible = true
	# Постріл
	if Input.is_action_just_pressed("shoot"): 
		if weapons[current_weapon_index].name == 'gun':
			if gun_recharge_timer >= gun_time_recharge:
				var inst = bullet_gun.instantiate()
				inst.transform = %ray_gun.global_transform
				get_tree().current_scene.add_child(inst)
				
				gun_recharge_timer = 0
				
		if weapons[current_weapon_index].name == 'rifle':
			if  %ray_rifle.is_colliding():
				var collide_obj = %ray_rifle.get_collider()
				if collide_obj.is_in_group('enemy'):
					collide_obj.damage(rifle_damage_amount)
					rifle_recharge_timer = 0
			
		
	# Керування переглядом мишкою
	if Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("mouse_left"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if Input.is_action_just_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED and event is InputEventMouseMotion:
		rotate_y(-event.relative.x * rotate_mouse_speed)
