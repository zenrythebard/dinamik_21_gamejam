class_name Player
extends CharacterBody3D

@onready var animation_tree: AnimationTree = $AnimationTree
@export var SPEED = 5.0
const JUMP_VELOCITY = 4.5
@onready var rotation_point: Node3D = $RotationPoint
var mouse_delta : Vector2  

func _ready() -> void:
	animation_tree.active = true
	Input.mouse_mode = 2

func _physics_process(delta: float) -> void:
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	if Input.is_action_just_pressed("esc") :
		if Input.mouse_mode == 2 :
			Input.mouse_mode = 0
			
		else :
			Input.mouse_mode = 2
		
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.

	var input_dir := Input.get_vector("walk_left", "walk_right", "walk_forward", "walk_backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).rotated(Vector3.UP, rotation_point.rotation.y).normalized()
	var anim_dir : Vector2
	anim_dir.x = input_dir.x
	anim_dir.y = -input_dir.y
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		
	move_and_slide()
	
	animation_tree["parameters/walk/blend_position"] = anim_dir
	
	if Input.is_action_just_pressed("attack") :
		if not animation_tree.get("parameters/oneshot_attack/active") :
			animation_tree["parameters/attack/blend_position"] = anim_dir
			animation_tree["parameters/oneshot_attack/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
			
				
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse_delta = event.relative
		rotation_point.rotation_degrees.y += (-mouse_delta.x * 0.2)
