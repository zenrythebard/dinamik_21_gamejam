class_name Ninja
extends CharacterBody3D

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@export var target : CharacterBody3D
@onready var player : CharacterBody3D = %Player
var target_pos : Vector3
var follow_player : bool = true
var player_in_range : bool = false
var attack_initiative : bool = true
var able_attack : bool = false
var attack_in_range : bool = false
var hover_in_range : bool = false
var retreat_step : bool = false
var finished_retreating : bool = false
var player_facing : Vector2 
@export var sprite: AnimatedSprite3D 
@export var animation_tree: AnimationTree 
@export var animation_player: AnimationPlayer  
var attack_timer : float = 0
@export var SPEED = 5.0
const JUMP_VELOCITY = 4.5
@export var attack_interval : float = 230


func _ready() -> void:
	animation_tree.active = true
	
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	# Handle jump.
	#if is_on_floor():
		#velocity.y = JUMP_VELOCITY
	move_and_slide()
	ninja_behaviour()
	direction_relative_to_player()

func ninja_behaviour():
	print(attack_initiative)
	#moving to zone control
	if not target or not follow_player:
		return
	if retreat_step:
		retreat_step_behaviour()
	elif attack_initiative:
		if attack_in_range:
			attack_behaviour()
		else:
			run_to_player()

	
	
func run_to_player():
	target_pos = target.position
	nav_agent.target_position = target_pos
	var next_path_pos : Vector3 = nav_agent.get_next_path_position()
	var direction : Vector3 = global_position.direction_to(next_path_pos)
	velocity = direction * SPEED
	animation_tree["parameters/walk/blend_position"] = player_facing
	animation_tree["parameters/blend_walk/blend_amount"] = 1

func retreat_step_behaviour():
	if attack_initiative == true:
		return
	animation_tree["parameters/walk/blend_position"] = player_facing
	animation_tree["parameters/blend_walk/blend_amount"] = 1
	if player_position_relative_x == "east" :
		velocity = Vector3(1,0,0)
	if player_position_relative_x == "west" :
		velocity = Vector3(-1,0,0)
	if player_position_relative_z == "south" :
		velocity = Vector3(0,0,-1)
	if player_position_relative_z == "north" :
		velocity = Vector3(0,0,1)
	if not player_in_range:
		retreat_step = false
		attack_initiative = true
	elif player_in_range:
		attack_timer += 1
		if attack_timer > attack_interval:
			attack_timer = 0
			retreat_step = false
			attack_initiative = true
	
func hover_behaviour():
	await get_tree().create_timer(0.1).timeout
	velocity.x = move_toward(velocity.x, 0, SPEED)
	velocity.z = move_toward(velocity.z, 0, SPEED)
	animation_tree["parameters/blend_walk/blend_amount"] = 0
	await get_tree().create_timer(0.5).timeout
	animation_tree["parameters/walk/blend_position"] = player_facing
	animation_tree["parameters/blend_walk/blend_amount"] = 1
	velocity.x = 2
	velocity.z = 2
	await get_tree().create_timer(2).timeout
	velocity.x = -2
	velocity.z = 2
	await get_tree().create_timer(2).timeout
	attack_initiative = true
	
	
func idle_behaviour():
	await get_tree().create_timer(0.1).timeout
	velocity.x = move_toward(velocity.x, 0, SPEED)
	velocity.z = move_toward(velocity.z, 0, SPEED)
	animation_tree["parameters/blend_walk/blend_amount"] = 0
	
func attack_behaviour():
		if animation_tree.get("parameters/oneshot_attack/active") == true:
			return
		attack_initiative = false
		animation_tree["parameters/attack/blend_position"] = player_facing
		animation_tree["parameters/oneshot_attack/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
		retreat_step = true
		#player #animation and collision to attack player (not finished)
		SPEED = 2

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
 

func _on_zone_of_control_body_exited(body: Node3D) -> void:
	if body is Player:
		player_in_range = false
		
func _on_zone_of_attack_body_entered(body: Node3D) -> void:
	if body is Player:
		attack_in_range = true
 
		
func _on_zone_of_attack_body_exited(body: Node3D) -> void:
	if body is Player:
		attack_in_range = false
		


func _on_zone_of_hover_body_entered(body: Node3D) -> void:
	if body is Player: 
		hover_in_range = true
		
func _on_zone_of_hover_body_exited(body: Node3D) -> void:
	if body is Player:
		hover_in_range = false
		
