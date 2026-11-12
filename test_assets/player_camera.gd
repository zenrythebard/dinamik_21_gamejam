extends Camera3D
@export var follow_object : CharacterBody3D
@export var follow_speed : float
@export var behind_character_offset : float

func _physics_process(delta: float) -> void:
	var weight = follow_speed / 10
	if follow_object == null:
		return
	global_position.x = lerp(global_position.x, follow_object.global_position.x, weight)
	global_position.z = lerp(global_position.z, follow_object.global_position.z - behind_character_offset, weight)
