class_name DebugHud extends Control 
@onready var debug_text : TextEdit = $DebugText
@export var fps_bool : bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	debug_text.text = "null"

func _process(delta: float) -> void:
	var fps_check : String 
	if fps_bool:
		fps_check = str(Engine.get_frames_per_second()) + "FPS" 
	else: 
		fps_check = ""
	debug_text.text = fps_check
