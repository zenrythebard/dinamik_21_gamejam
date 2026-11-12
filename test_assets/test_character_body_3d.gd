extends CharacterBody3D

@onready var movement_tree: AnimationTree = $MovementTree
@export var SPEED = 5.0
const JUMP_VELOCITY = 4.5
@onready var rotation_point: Node3D = $RotationPoint
var mouse_delta : Vector2  

func _ready() -> void:
	movement_tree.active = true

func _physics_process(delta: float) -> void:
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.

	var input_dir := Input.get_vector("walk_left", "walk_right", "walk_forward", "walk_backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).rotated(Vector3.UP, rotation_point.rotation.y).normalized()
	var anim_dir : Vector2
	anim_dir.x = direction.x
	anim_dir.y = -direction.z
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		
	move_and_slide()
	print (direction)
	
	movement_tree["parameters/walk/blend_position"] = anim_dir
	
	if Input.is_action_just_pressed("attack") :
		movement_tree["parameters/attack/blend_position"] = anim_dir
		movement_tree["parameters/oneshot_attack/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse_delta = event.relative
		rotation_point.rotation_degrees.y += (-mouse_delta.x * 0.2)
