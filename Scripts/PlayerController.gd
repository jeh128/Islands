extends KinematicBody

export var speed: float = 5
export var jump_strength: float = 15
export var max_air_jumps: int = 1
export var x_sensitivity: float = 0.004
export var y_sensitivity: float = 0.002

var air_jumps: int = 0
var velocity: Vector3 = Vector3.ZERO
var camera_input: Vector2 = Vector2.ZERO

var pivot: Spatial
var mesh: Spatial

const GRAVITY: float = -9.8 * 3

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	pivot = get_node("CameraPivot")
	mesh = get_node("MeshInstance")
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		camera_input = Vector2(event.relative.x * x_sensitivity, event.relative.y * y_sensitivity)

func _physics_process(delta: float) -> void:
	# free mouse cursor on esc
	if Input.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		
	# camera
	pivot.rotate_x(-camera_input.y)
	rotate_y(-camera_input.x)
	camera_input = Vector2.ZERO
	pivot.rotation_degrees.x = clamp(pivot.rotation_degrees.x, -90, 90)
	
	# movement
	var movement: Vector3 = Vector3.ZERO
	
	if is_on_floor():
		air_jumps = max_air_jumps
		if Input.is_action_just_pressed("jump"):
			velocity.y += jump_strength
	elif air_jumps > 0:
		if Input.is_action_just_pressed("jump"):
			velocity.y = jump_strength
			air_jumps -= 1
	
	velocity.y += GRAVITY * delta
	
	if Input.is_action_pressed("forward"):
		movement += transform.basis * Vector3.FORWARD
	
	if Input.is_action_pressed("backward"):
		movement += transform.basis * Vector3.BACK
	
	if Input.is_action_pressed("left"):
		movement += transform.basis * Vector3.LEFT
	
	if Input.is_action_pressed("right"):
		movement += transform.basis * Vector3.RIGHT
		
	if movement.length_squared() > 1:
		movement = movement.normalized()
	
	velocity = move_and_slide(velocity + movement * speed, Vector3.UP) - movement * speed
	
	#update mesh rotation
	mesh.set_rotation(velocity.cross(transform.basis * Vector3.FORWARD)) #lol
