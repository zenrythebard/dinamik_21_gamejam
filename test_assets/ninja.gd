class_name Ninja
extends CharacterBody3D

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@export var target : CharacterBody3D
@onready var player : CharacterBody3D = %Player
var target_pos : Vector3
var follow_player : bool = true
var player_in_range : bool = false
var first_strike : bool = true
var player_facing : int = 1
@onready var sprite: AnimatedSprite3D = $AnimatedSprite3D
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var SPEED = 5.0
const JUMP_VELOCITY = 4.5
	
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	#if is_on_floor():
		#velocity.y = JUMP_VELOCITY
	ninja_behaviour()
	print (await delta_distance_to_player_calc())
	move_and_slide()

func ninja_behaviour():
	if target:
		if follow_player:
			if player_in_range == false:
				run_to_player()
			elif first_strike == true:
				run_to_player()
			else:
				velocity.x = move_toward(velocity.x, 0, SPEED)
				velocity.z = move_toward(velocity.z, 0, SPEED)
				animation_player.play("idle")
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		animation_player.play("idle")

func run_to_player():
	target_pos = target.position
	nav_agent.target_position = target_pos
	var next_path_pos : Vector3 = nav_agent.get_next_path_position()
	var direction : Vector3 = global_position.direction_to(next_path_pos)
	velocity = direction * SPEED
	animation_player.play("walk_backward")
	
func delta_distance_to_player_calc() -> bool:
	var prev_dis : float
	var cur_dis : float
	var diff_closer : bool
	prev_dis = global_position.distance_to(player.global_position)
	await get_tree().create_timer(1).timeout
	cur_dis = global_position.distance_to(player.global_position)
	if prev_dis > cur_dis:
		diff_closer = true
	else:
		diff_closer = false
	return diff_closer
	

func _on_zone_of_control_body_entered(body: Node3D) -> void:
	if body is Player:
		player_in_range = true
		print("inside")

func _on_zone_of_control_body_exited(body: Node3D) -> void:
	if body is Player:
		player_in_range = false
		
