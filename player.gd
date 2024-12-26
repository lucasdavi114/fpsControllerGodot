extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

@export var SENSIBILIDADE_MOUSE : float = 0.5
@export var TILT_LOWER_LIMIT := deg_to_rad(-90.0)
@export var TILT_UPPER_LIMIT := deg_to_rad(90.0)
@export var CAMERA_CONTROLLER : Camera3D

var mouseInput : bool = false
var mouseRotation : Vector3
var rotationInput : float
var tiltInput : float
var cameraRotation : Vector3
var playerRotation : Vector3

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("exit"):
		get_tree().quit()

func _unhandled_input(event: InputEvent) -> void:
	mouseInput = event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	if mouseInput:
		rotationInput = -event.relative.x * SENSIBILIDADE_MOUSE
		tiltInput = -event.relative.y * SENSIBILIDADE_MOUSE

func _update_camera(delta):
	mouseRotation.x += tiltInput * delta
	mouseRotation.x = clamp(mouseRotation.x, TILT_LOWER_LIMIT, TILT_UPPER_LIMIT)
	mouseRotation.y += rotationInput * delta
	
	playerRotation = Vector3(0.0, mouseRotation.y, 0.0)
	cameraRotation = Vector3(mouseRotation.x, 0.0, 0.0)
	
	CAMERA_CONTROLLER.transform.basis = Basis.from_euler(cameraRotation)
	CAMERA_CONTROLLER.rotation.z = 0.0
	
	global_transform.basis = Basis.from_euler(playerRotation)
	
	rotationInput = 0.0
	tiltInput = 0.0
	
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	_update_camera(delta)
	
	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

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

	move_and_slide()
