extends CharacterBody3D

const SPEED = 5.0
const CROUCH_SPEED = 2.0
const JUMP_VELOCITY = 4.5
@export var sensitivity = 3
var FlashLightIsOut : bool
var crouched : bool

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	crouched = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("MoveLeft", "MoveRight", "MoveForward", "MoveBackward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if Input.is_action_just_pressed("FlashLight"):
		if FlashLightIsOut:
			$AnimationPlayer.play("FlashLightHide")
		else:
			$AnimationPlayer.play("FlashLightShow")
		FlashLightIsOut = !FlashLightIsOut

	var local_speed : float
	if Input.is_action_pressed("Crouch"):
		local_speed = CROUCH_SPEED	
		if !crouched:
			$AnimationPlayer.play("Crouch")
			crouched = true
	else:
		local_speed = SPEED
		if crouched:
			var space_state = get_world_3d().direct_space_state
			var result = space_state.intersect_ray(PhysicsRayQueryParameters3D.create(position, position + Vector3(0, 2, 0), 1, [self]))
			if result.size() == 0:
				$AnimationPlayer.play("UnCrouch")
				crouched = false

	if direction:
		velocity.x = direction.x * local_speed
		velocity.z = direction.z * local_speed
	else:
		velocity.x = move_toward(velocity.x, 0, local_speed)
		velocity.z = move_toward(velocity.z, 0, local_speed)

	move_and_slide()

func _input(event):
	if event is InputEventMouseMotion:
		rotation.y -= event.relative.x / 1000 * sensitivity
		$camera.rotation.x -= event.relative.y / 1000 * sensitivity
		rotation.x = clamp(rotation.x, -PI/2, PI/2)
		$camera.rotation.x = clamp($camera.rotation.x, -2, 2)
