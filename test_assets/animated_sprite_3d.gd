@tool
extends AnimatedSprite3D

var shader_material : ShaderMaterial

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	shader_material = material_overlay
	shader_material.set_shader_parameter("tex", sprite_frames.get_frame_texture(animation, frame))
	
func _on_frame_changed() -> void:
	shader_material.set_shader_parameter("tex", sprite_frames.get_frame_texture(animation, frame))
