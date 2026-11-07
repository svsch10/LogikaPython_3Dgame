extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const rotate_mouse_speed = 0.02

const gun_time_recharge = 0.5
var gun_recharge_timer = gun_time_recharge

const rifle_time_recharge = 2
var rifle_recharge_timer = rifle_time_recharge

const sniper_rifle_recharge = 3
var sniper_rifle_recharge_timer = sniper_rifle_recharge

const FOV_DEFAULT = 75
const FOV_SNIPER = 10

# Зброя
@onready var gun = $hero/Armature/Skeleton3D/Bone_007/gun
@onready var rifle = $hero/Armature/Skeleton3D/Bone_007/rifle
var sniper_rifle = {'name': 'sniper_rifle', 'visible': false}

var rifle_damage_amount = 3
var sniper_rifle_damage_amount = 5

@onready var weapons = [gun]
var current_weapon_index = 0

@onready var anim_player = $hero/AnimationPlayer

@onready var bullet_gun = load("res://bullet.tscn")

var hp = 10


func _ready() -> void:
	%camera3p.current = true
	%rifle_cross.visible = false
	%sniper_rifle_cross.visible = false
	%vignette.visible = false
	
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
	sniper_rifle_recharge_timer += delta

	move_and_slide()
	
	# Підбирання об'єктів
	for ind in get_slide_collision_count():
		var col = get_slide_collision(ind).get_collider()
		
		if col.name == "rifle":
			weapons.append(rifle)
			col.queue_free()
			
		if col.name == "sniper_rifle":
			weapons.append(sniper_rifle)
			col.queue_free()
	
	
func _input(event: InputEvent) -> void:
	# Зміна зброї
	if Input.is_action_just_pressed("change_weapon"):
		weapons[current_weapon_index].visible = false
		current_weapon_index = (current_weapon_index + 1) % weapons.size()
		weapons[current_weapon_index].visible = true
		
		# Руки
		var hands = $hero/Armature/Skeleton3D/hands
		# Зміна виду
		if weapons[current_weapon_index].name == 'gun':
			%camera3p.current = true
			%rifle_cross.visible = false
			%sniper_rifle_cross.visible = false
			%vignette.visible = false
			hands.visible = true
		else:
			$camera1p.current = true
			if weapons[current_weapon_index].name == 'rifle':
				$camera1p.fov = FOV_DEFAULT
				%rifle_cross.visible = true
			elif weapons[current_weapon_index].name == 'sniper_rifle':
				$camera1p.fov = FOV_SNIPER
				%rifle_cross.visible = false
				%sniper_rifle_cross.visible = true
				%vignette.visible = true
				hands.visible = false
				
				
	# Постріл
	if Input.is_action_just_pressed("shoot"): 
		if weapons[current_weapon_index].name == 'gun':
			if gun_recharge_timer >= gun_time_recharge:
				var inst = bullet_gun.instantiate()
				inst.transform = %ray_gun.global_transform
				get_tree().current_scene.add_child(inst)
				
				gun_recharge_timer = 0
				
		if weapons[current_weapon_index].name == 'rifle':
			if rifle_recharge_timer >= rifle_time_recharge:
				if  %ray_rifle.is_colliding():
					var collide_obj = %ray_rifle.get_collider()
					if collide_obj.is_in_group('enemy'):
						collide_obj.damage(rifle_damage_amount)
						
						rifle_recharge_timer = 0
						
		if weapons[current_weapon_index].name == 'sniper_rifle':
			if sniper_rifle_recharge_timer >= sniper_rifle_recharge:
				if %ray_sniper_rifle.is_colliding():
					var collide_obj = %ray_sniper_rifle.get_collider()
					if collide_obj.is_in_group('enemy'):
						collide_obj.damage(sniper_rifle_damage_amount)
						
						sniper_rifle_recharge_timer = 0
			
		
	# Керування переглядом мишкою
	if Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("mouse_left"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if Input.is_action_just_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED and event is InputEventMouseMotion:
		rotate_y(-event.relative.x * rotate_mouse_speed)
		if weapons[current_weapon_index].name == 'sniper_rifle':
			%camera1p.rotate_x(-event.relative.y * rotate_mouse_speed)
			%camera1p.rotation.x = clamp(%camera1p.rotation.x, -deg_to_rad(45), deg_to_rad(45))


func damage(amount=1):
	hp -= amount
	if hp <= 0:
		print("GAME OVER!")
		get_tree().paused = true
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
