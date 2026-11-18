class_name Player
extends CharacterBody3D

@onready var hurtbox: Area3D = $RotationPoint/Hurtbox
@onready var animation_tree: AnimationTree = $AnimationTree
@export var base_speed : float
@export var dash_strength : float
var SPEED : float
const JUMP_VELOCITY = 4.5
@onready var rotation_point: Node3D = $RotationPoint
var mouse_delta : Vector2  
@export var base_health : float = 100
var health : float
@export var base_damage : float = 5
var damage : float
signal player_death
var overload_value : float

func _ready() -> void:
	damage = base_damage
	health = base_health
	SPEED = base_speed
	animation_tree.active = true
	Input.mouse_mode = 2
	player_death.connect(on_death)
	overload_value = clampf(0.0, 0.0, 300)
	
func _physics_process(delta: float) -> void:
	var h_clamp = clampf(health, 0.0, base_health)
	health = h_clamp
	var o_clamp = clampf(overload_value, 0.0, 300)
	overload_value = o_clamp
	
	print (overload_value)
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
	
	if Input.is_action_just_pressed("dash") :
		if not animation_tree.get("parameters/oneshot_dash/active") :
			SPEED = base_speed + dash_strength
			animation_tree["parameters/dash/blend_position"] = anim_dir
			animation_tree["parameters/oneshot_dash/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
			await animation_tree.animation_finished
			SPEED = base_speed
		overload_value += 5
		
	move_and_slide()
	move_and_collide(knockback)
	knockback = knockback.move_toward(Vector3.ZERO, 0.1)
	
	animation_tree["parameters/walk/blend_position"] = anim_dir
	
	if Input.is_action_just_pressed("attack") :
		if not animation_tree.get("parameters/oneshot_attack/active") :
			animation_tree["parameters/attack/blend_position"] = anim_dir
			animation_tree["parameters/oneshot_attack/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
		overload_value += 10
				
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse_delta = event.relative
		rotation_point.rotation_degrees.y += (-mouse_delta.x * 0.2)

var prev_facing_direction : Vector2

func _on_front_body_entered(body: Ninja) -> void:
	body.player_facing.y = 1
	prev_facing_direction.y = 1
 
func _on_front_body_exited(body: Ninja) -> void:
	body.player_facing.y = 0
	if prev_facing_direction.x == 1:
		body.player_facing.x = 1
	else:
		body.player_facing.x = -1

func _on_left_body_entered(body: Ninja) -> void:
	body.player_facing.x = 1
	prev_facing_direction.x = 1

func _on_left_body_exited(body: Ninja) -> void:
	body.player_facing.x = 0
	if prev_facing_direction.y == 1:
		body.player_facing.y = 1
	else:
		body.player_facing.y = -1
	
func _on_right_body_exited(body: Ninja) -> void:
	body.player_facing.x = 0
	if prev_facing_direction.y == 1:
		body.player_facing.y = 1
	else:
		body.player_facing.y = -1

func _on_right_body_entered(body: Ninja) -> void:
	body.player_facing.x = -1
	prev_facing_direction.x = -1

func _on_back_body_exited(body: Ninja) -> void:
	body.player_facing.y = 0
	if prev_facing_direction.x == 1:
		body.player_facing.x = 1
	else:
		body.player_facing.x = -1
	
func _on_back_body_entered(body: Ninja) -> void:
	body.player_facing.y = -1
	prev_facing_direction.y = -1
	

var knockback : Vector3
@export var weight : float = 1
func _on_hitbox_area_entered(area: HurtboxNinja) -> void:
	health -= area.main_body.damage
	var knock_dir : Vector3 = -(area.global_position - global_position).normalized()
	knockback = knock_dir * 10 / weight
	if health < 1:
		emit_signal("player_death")
		
func on_death():
	Input.mouse_mode = 0
	queue_free()

@onready var overload_decay: Timer = $OverloadValueTimer
func overload_meter() :
	if overload_value >= 0:
		
		return
	
