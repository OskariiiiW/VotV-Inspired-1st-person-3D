extends CharacterBody3D

@onready var head: Node3D = $Head
@onready var collision: CollisionShape3D = $Collision
@onready var half_collision: CollisionShape3D = $HalfCollision
@onready var m_ray_cast: RayCast3D = $Head/MainRayCast
@onready var camera: Camera3D = $Head/Camera3D
@onready var drop_pos_marker: Marker3D = $Head/DropPosMarker
@onready var grab_pos_marker: Marker3D = $Head/GrabPosMarker
@onready var vc_ray_cast: RayCast3D = $VaultCheckRayCast
@onready var v_ray_cast: RayCast3D = $VaultRayCast
@onready var c_ray_cast: RayCast3D = $CrouchRayCast
@onready var s_b_ray_cast: RayCast3D = $StairsBottomRayCast
@onready var s_t_ray_cast: RayCast3D = $StairsTopRayCast
@onready var audio_streamer: AudioStreamPlayer3D = $AudioStreamPlayer3D

@export var GUI : CanvasLayer

enum State {DEFAULT, SPRINT, JUMP, FALL, CROUCH, VAULT, CLIMB, SIT}

const SPEED = 5.0
const JUMP_VELOCITY = 4.0
const LERP_VAL = .15 # DevLogLogan tutorial
const MOUSE_SENS = 0.3
const FOV = 75
const ZOOM_FOV = 30

var speed_mult = 1.0
var fov_step = 3 # zoom speed
var crouch_step = 0.05 # how quickly crouch "animation" happens

var state : State
var action_queued : bool
var grav_enabled : bool
var is_ragdoll : bool
var can_move : bool = true
var can_rotate : bool = true

var interact_obj
var is_grabbing : bool
var grab_held : bool
var grab_rotate_held : bool
var btn_hold_timer : int

#TODO - change grab target pos to the point where raycast collides on object
	# would instead need center of mass changed to point of collision??
# possible bug where player is freed from !can_move by closing inv

func _ready() -> void:
	Input.mouse_mode =Input.MOUSE_MODE_CAPTURED
	grav_enabled = true

func set_state(_state : State):
	if _state == State.DEFAULT:
		print("defaulting")
		speed_mult = 1.0
		state = State.DEFAULT
	elif _state == State.CROUCH:	# Crouch
		print("crouching")
		speed_mult = 0.7
		collision.disabled = true
		half_collision.disabled = false
		state = State.CROUCH
	elif _state == State.SPRINT:	# Sprint
		print("sprinting")
		speed_mult = 1.5
		state = State.SPRINT
	elif _state == State.JUMP:		# Jump
		print("jumping")
		state = State.JUMP
	elif _state == State.FALL:		# Fall
		print("falling")
		if state == State.CLIMB:
			speed_mult = 0.3
		state = State.FALL
	elif _state == State.VAULT:		# Vault
		print("vaulting")
		speed_mult = 1.0
		state = State.VAULT
	elif _state == State.CLIMB:		# Climb
		print("climbing")
		grav_enabled = false
		velocity = Vector3.ZERO # Resets existing velocity so player doesnt float away
		state = State.CLIMB
	elif _state == State.SIT:		# Sit
		print("sitting")
		collision.disabled = true
		half_collision.disabled = true
		grav_enabled = false
		velocity = Vector3.ZERO # Resets existing velocity so player doesnt float away
		state = State.SIT

func _physics_process(delta: float) -> void:
	# Gravity
	if not is_on_floor():
		if grav_enabled:
			velocity += get_gravity() * delta

	# One time command to uncrouch if previously not possible
	if action_queued:
		if !c_ray_cast.is_colliding():
			crouch(false)

	if can_move:
		# Jump & Vault
		if Input.is_action_just_pressed("jump"):
			if is_on_floor():
				if v_ray_cast.is_colliding() and !vc_ray_cast.is_colliding():
					vault()
				else:
					jump()
			elif v_ray_cast.is_colliding() and !vc_ray_cast.is_colliding():
				if velocity.y >= -0.5:
					vault()

		# Sprint
		if Input.is_action_just_pressed("sprint") and state == State.DEFAULT and is_on_floor():
			set_state(State.SPRINT)
		if Input.is_action_just_released("sprint") and state == State.SPRINT and is_on_floor():
			set_state(State.DEFAULT)

		# Interact & Grab
		if Input.is_action_just_pressed("interact"): # sets the obj to be interacted
			if m_ray_cast.is_colliding():
				var obj = m_ray_cast.get_collider()
				if obj.is_in_group("grabbable"):
					interact_obj = obj
					grab_held = true
				elif obj.is_in_group("interactable"):
					print(obj.name + " (playercharacter)")
					obj.interact(self)
				else:
					audio_streamer.play() # cannot be grabbed sound
			else:
				audio_streamer.play() # nothing to grab sound
		if Input.is_action_pressed("interact"): # keeps btn held counter and grab start
			if interact_obj:
				if grab_held:
					btn_hold_timer += 1
				if btn_hold_timer > 15 and !is_grabbing: # timer amount might need adjustment
					is_grabbing = true
					#sa
					interact_obj.grab(self)
		if Input.is_action_just_released("interact"): # handles interact and obj "freeing"
			if interact_obj:
				if btn_hold_timer <= 10:
					if interact_obj.is_in_group("interactable"):
						print(interact_obj.name + " (playercharacter)")
						interact_obj.interact(self)
					else:
						audio_streamer.play() # cannot be interacted sound
				release_grabbed_obj()

		# Attack & Throw
		if Input.is_action_just_pressed("left_mouse"):
			if is_grabbing:
				interact_obj.release()
				const impulse_strength = 7
				var angle = -head.global_transform.origin + grab_pos_marker.global_transform.origin
				interact_obj.apply_central_impulse(angle * impulse_strength)

		# Grabbed object rotation
		if Input.is_action_just_pressed("grab_rotate"):
			if is_grabbing:
				grab_rotate_held = true
		if Input.is_action_just_released("grab_rotate"):
			if is_grabbing:
				grab_rotate_held = false

		# Crouch
		if Input.is_action_pressed("crouch") and is_on_floor():
			crouch(true)
		if Input.is_action_just_released("crouch"):
			crouch(false)

	if can_rotate:
		# Zoom
		if Input.is_action_pressed("camera_zoom"):
			if camera.fov > ZOOM_FOV:
				camera.fov -= fov_step
		if Input.is_action_just_released("camera_zoom"):
			camera.fov = FOV

	# Pause menu
	if Input.is_action_just_pressed("ui_cancel"):
		if state == State.SIT:
			set_state(State.DEFAULT)
			collision.disabled = false
			reparent(get_parent().get_parent())
			self.rotation = Vector3(0, self.rotation.y, 0)
		elif GUI.inventory_gui.visible == true:
			GUI.close_menu()
		else:
			get_tree().quit()

	# Movement
	if can_move:
		var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if state == State.DEFAULT:
			basic_movement(direction)
		elif state == State.CROUCH:
			basic_movement(direction)
		elif state == State.SPRINT:
			basic_movement(direction)
		elif state == State.JUMP:
			jump_movement(direction)
		elif state == State.FALL:
			fall_movement(direction)
		elif state == State.VAULT:
			vault_movement(direction)
		elif state == State.CLIMB:
			climb_movement(input_dir)
		elif state == State.SIT:
			pass
	else:
		velocity.x = lerp(velocity.x, 0.0, LERP_VAL)
		velocity.z = lerp(velocity.z, 0.0, LERP_VAL)
	_push_away_rigid_bodies()
	move_and_slide()

func release_grabbed_obj(): # if player gets too far from grabbed obj
	interact_obj.release()
	is_grabbing = false
	interact_obj = null
	btn_hold_timer = 0

func _push_away_rigid_bodies(): # from Majikayo Games YT
	for i in get_slide_collision_count():
		var c := get_slide_collision(i)
		if c.get_collider() is RigidBody3D:
			var push_dir = -c.get_normal()
			# How much velocity the object needs to increase to match player velocity in the push direction
			var velocity_diff_in_push_dir = self.velocity.dot(push_dir) - c.get_collider().linear_velocity.dot(push_dir)
			# Only count velocity towards push dir, away from character
			velocity_diff_in_push_dir = max(0., velocity_diff_in_push_dir)
			# Objects with more mass than us should be harder to push
			const MY_APPROX_MASS_KG = 80.0
			var mass_ratio = min(1., MY_APPROX_MASS_KG / c.get_collider().mass)
			# Don't push object from above/below
			push_dir.y = 0
			# 5.0 is a magic number, adjust to your needs
			var push_force = mass_ratio * 4.0
			c.get_collider().apply_impulse(push_dir * velocity_diff_in_push_dir * push_force\
			, c.get_position() - c.get_collider().global_position)
			# using impulse instead of force bc it feels smoother

func basic_movement(direction):
	if direction:
		velocity.x = lerp(velocity.x, direction.x * (SPEED * speed_mult), LERP_VAL)
		velocity.z = lerp(velocity.z, direction.z * (SPEED * speed_mult), LERP_VAL)
		if s_b_ray_cast.is_colliding() and !s_t_ray_cast.is_colliding():
			velocity.y += 0.25
	else:
		velocity.x = lerp(velocity.x, 0.0, LERP_VAL)
		velocity.z = lerp(velocity.z, 0.0, LERP_VAL)

	if velocity.y < 0:
		set_state(State.FALL)

func jump_movement(direction):
	if is_on_floor():
		set_state(State.DEFAULT)

	if direction:
		velocity.x = lerp(velocity.x, direction.x * (SPEED * speed_mult), LERP_VAL)
		velocity.z = lerp(velocity.z, direction.z * (SPEED * speed_mult), LERP_VAL)
	else:
		velocity.x = lerp(velocity.x, 0.0, LERP_VAL)
		velocity.z = lerp(velocity.z, 0.0, LERP_VAL)

	if velocity.y < 0:
		set_state(State.FALL)

func fall_movement(direction):
	if !is_ragdoll:
		if direction:
			velocity.x = lerp(velocity.x, direction.x * (SPEED * speed_mult), LERP_VAL)
			velocity.z = lerp(velocity.z, direction.z * (SPEED * speed_mult), LERP_VAL)
		else:
			velocity.x = lerp(velocity.x, 0.0, LERP_VAL)
			velocity.z = lerp(velocity.z, 0.0, LERP_VAL)

	if velocity.y < -9:
		action_queued = true # hard fall
	if is_on_floor(): # if already ragdolled maybe wait until all velocity < 1?
		if action_queued:
			print("que ragdoll")
		set_state(State.DEFAULT)

func vault_movement(direction):
	velocity.y = JUMP_VELOCITY * 0.8
	velocity.x = direction.x
	velocity.z = direction.z

func climb_movement(direction):
	velocity.y = -direction.y * SPEED
	velocity.x = direction.x * (SPEED * 0.1)

	if is_on_floor() and velocity.y < 0:
		set_state(State.DEFAULT)

	# Handle Jump
func jump():
	velocity.y = JUMP_VELOCITY
	await get_tree().create_timer(0.1).timeout
	set_state(State.JUMP)

	# Handle Vault
func vault():
	set_state(State.VAULT)
	grav_enabled = false
	collision.disabled = true
	await get_tree().create_timer(0.4).timeout
	grav_enabled = true
	collision.disabled = false
	set_state(State.FALL)

	# Handle Crouch
func crouch(crouching : bool):
	if crouching:
		if state != State.CROUCH:
			set_state(State.CROUCH)
		if head.position.y > -0.1:
			head.position.y -= crouch_step
	else:
		if !c_ray_cast.is_colliding():
			collision.disabled = false
			half_collision.disabled = true
			head.position.y = 0.4
			action_queued = false
			set_state(State.DEFAULT)
		else:
			action_queued = true

func sit(pos : Vector3, new_rotation : Vector3):
	if state != State.SIT: # stops sit spamming while already sitting (could have caused problems later)
		self.position = pos
		self.rotation = new_rotation
		set_state(State.SIT)

func handle_menu_open():
	Input.mouse_mode =Input.MOUSE_MODE_VISIBLE
	can_move = false
	can_rotate = false

func handle_menu_close():
	Input.mouse_mode =Input.MOUSE_MODE_CAPTURED
	can_move = true
	can_rotate = true

	# Mouse rotation
func _input(event):
	if can_rotate:
		if event is InputEventMouseMotion:
			if !grab_rotate_held:
				rotate_y(deg_to_rad(-event.relative.x * MOUSE_SENS))
				head.rotate_x(deg_to_rad(-event.relative.y * MOUSE_SENS))
				head.rotation.x = clamp(head.rotation.x,deg_to_rad(-89),deg_to_rad(89))
			else:
				interact_obj.rotate_y(deg_to_rad(-event.relative.x * (MOUSE_SENS * 0.5)))
				interact_obj.rotate_x(deg_to_rad(-event.relative.y * (MOUSE_SENS * 0.5)))
