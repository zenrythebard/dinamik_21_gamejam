class_name Ninja
extends CharacterBody3D

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@export var target : CharacterBody3D
@onready var player : CharacterBody3D = %Player
var target_pos : Vector3
var follow_player : bool = true
var player_in_range : bool = false
var first_strike : bool = false
var able_attack : bool = false
var attack_in_range : bool = false
var player_facing : Vector2 
@export var sprite: AnimatedSprite3D 
@export var animation_tree: AnimationTree 
@export var animation_player: AnimationPlayer  

@export var SPEED = 5.0
const JUMP_VELOCITY = 4.5
	
func _ready() -> void:
	animation_tree.active = true
	
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	#if is_on_floor():
		#velocity.y = JUMP_VELOCITY
	ninja_behaviour()
	move_and_slide()
	direction_relative_to_player()

func ninja_behaviour():
	#moving to zone control
	if target:
		if follow_player:
			if player_in_range == false:
				run_to_player()
			elif first_strike == true:
				attack_behaviour()
			else:
				hover_behaviour()
	else:
		idle_behaviour()
	
	
func run_to_player():
	await get_tree().create_timer(0.1).timeout
	target_pos = target.position
	nav_agent.target_position = target_pos
	var next_path_pos : Vector3 = nav_agent.get_next_path_position()
	var direction : Vector3 = global_position.direction_to(next_path_pos)
	velocity = direction * SPEED
	animation_tree["parameters/walk/blend_position"] = player_facing
	animation_tree["parameters/blend_walk/blend_amount"] = 1
	
func hover_behaviour():
	
	return
	
func idle_behaviour():
	await get_tree().create_timer(0.1).timeout
	velocity.x = move_toward(velocity.x, 0, SPEED)
	velocity.z = move_toward(velocity.z, 0, SPEED)
	animation_tree["parameters/blend_walk/blend_amount"] = 0
	
func attack_behaviour():
	if attack_in_range == false :
		run_to_player()
	else :
		animation_tree["parameters/walk/blend_position"] = player_facing
		animation_tree["parameters/oneshot_attack/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
		print ("attacked")
		player #animation and collision to attack player (not finished)
		first_strike = false
		
var player_position_relative_x : String
var player_position_relative_z : String

func direction_relative_to_player () :
	if player.global_position.x > global_position.x:
		player_position_relative_x = "east"
	if player.global_position.x < global_position.x:
		player_position_relative_x = "west"
	if player.global_position.z > global_position.z:
		player_position_relative_z = "south"
	if player.global_position.z < global_position.z:
		player_position_relative_z = "north"
	
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
		
func _on_zone_of_attack_body_entered(body: Node3D) -> void:
	if body is Player:
		attack_in_range = true
		print ("attack_able")
		
func _on_zone_of_attack_body_exited(body: Node3D) -> void:
	if body is Player:
		attack_in_range = false
		
