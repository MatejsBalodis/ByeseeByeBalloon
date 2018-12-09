extends Sprite

onready var main_character_camera = get_parent().get_parent().get_parent().get_node("CharacterLayer").get_node("MainCharacter").get_node("Camera2D") # For speed and convenience.
const BOTTOM_LINE_OFFSET = 1380.0 # To avoid having magic numbers.
const BLINK_PHASE = .01 # How quickly to blink the bottom line.

func _process(delta):
	if Global.current_level_stop_state == Global.Level_stop_states.NONE:
		modulate.a = sin(OS.get_ticks_msec() * BLINK_PHASE)
	else:
		modulate.a = lerp(modulate.a, .0, delta)

func _physics_process(delta):
	position.y = main_character_camera.original_y_position + BOTTOM_LINE_OFFSET - main_character_camera.get_camera_position().y
