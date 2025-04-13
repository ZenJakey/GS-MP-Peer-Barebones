extends CharacterBody3D



@export var walking_speed = 3.0
@export var running_speed = 5.0
@export var h_cam_sensitivity = 0.5
@export var v_cam_sensitivity = 0.5
var running = false

@export var JUMP_VELOCITY = 4.5
@export var CAMERA_SPEED = 0.5
@export var STEAM_ID = 0
@onready var animation_player: AnimationPlayer = $visuals/mixamo_base/AnimationPlayer
@onready var visuals: Node3D = $visuals
@onready var player: CharacterBody3D = $"."
@onready var camera_3d: Camera3D = $Camera3D

func _ready() -> void:
	if !is_multiplayer_authority():
		camera_3d.queue_free()
		visuals.show()
	else:
		visuals.hide()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
func _input(event: InputEvent) -> void:
	if !is_multiplayer_authority():
		return
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * CAMERA_SPEED * h_cam_sensitivity))
		camera_3d.rotate_x(deg_to_rad(-event.relative.y * CAMERA_SPEED * v_cam_sensitivity))
		if(camera_3d.rotation.x > 1):
			camera_3d.rotation.x = 1
		if(camera_3d.rotation.x < -1):
			camera_3d.rotation.x = -1
		

func _physics_process(delta: float) -> void:
	if !is_multiplayer_authority():
		return
	
	var speed = walking_speed
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("character_jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	if Input.is_action_pressed("run"):
		speed = running_speed
		running = true
	else: 
		running = false

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("character_left", "character_right", "character_forward", "character_backwards")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		if running and animation_player.current_animation != "runninng":
			animation_player.play("running")
		elif animation_player.current_animation != "walking":
			animation_player.play("walking")
		visuals.look_at(position + direction)
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		if animation_player.current_animation != "idle":
			animation_player.play("idle")
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()
