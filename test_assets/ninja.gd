extends CharacterBody3D
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@export var target : CharacterBody3D
@onready var player : CharacterBody3D = %Player
var target_pos : Vector3
var follow : bool = true
@onready var sprite: AnimatedSprite3D = $AnimatedSprite3D

@export var SPEED = 5.0
const JUMP_VELOCITY = 4.5
	
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	if target:
		if follow:
			target_pos = target.position
			nav_agent.target_position = target_pos
			var next_path_pos : Vector3 = nav_agent.get_next_path_position()
			var direction : Vector3 = global_position.direction_to(next_path_pos)
			velocity = direction * SPEED
	
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
 

	move_and_slide()
