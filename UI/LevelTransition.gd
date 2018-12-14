extends TextureRect

onready var lerp_progress = .0 # To have tight control over lerping.
onready var current_transition_is_in_progress = true # To correctly initiate lerp progress.
onready var quit_game_func = funcref(get_tree(), "quit") # For speed and convenience.
onready var switch_scene_func = funcref(Global, "goto_scene") # For speed and convenience.

var previous_level_stop_state = Global.current_level_stop_state # To initiate the transition just once.

const TRANSITION_SPEED = 2.0 # How quickly to lerp in and out of transition.
const TRANSITION_BOUNDS = Vector2(.0, 1.0) # From where to where to do the transition.

func _ready():
	Global.level_transition = self
	modulate.a = 1.0
	Global.current_level_stop_state = Global.Level_stop_states.TRANSITION_IN

func _process(delta):
	var current_level_stop_state = Global.current_level_stop_state # To avoid code duplication.
	if Global.current_level_stop_state == Global.Level_stop_states.TRANSITION_IN:
		if lerp_progress < 1.0:
			lerp_progress += delta * TRANSITION_SPEED
			modulate.a = lerp(TRANSITION_BOUNDS.y, TRANSITION_BOUNDS.x, lerp_progress)
		else:
			Global.current_level_stop_state = Global.Level_stop_states.NONE
			current_transition_is_in_progress = false
	elif Global.current_level_stop_state == Global.Level_stop_states.TRANSITION_OUT:
		transition_out_and_finish(Global.current_level_stop_state, switch_scene_func, delta)
	elif Global.current_level_stop_state == Global.Level_stop_states.QUIT_GAME:
		transition_out_and_finish(Global.current_level_stop_state, quit_game_func, delta)
	elif Global.current_level_stop_state == Global.Level_stop_states.SWITCH_LEVEL_OUT:
		transition_out_and_finish(Global.current_level_stop_state, null, delta)
	previous_level_stop_state = Global.current_level_stop_state

func transition_out_and_finish(current_level_stop_state, finish_func, delta):
	if previous_level_stop_state != current_level_stop_state:
		if !current_transition_is_in_progress:
			lerp_progress = 1.0
		current_transition_is_in_progress = true
	if lerp_progress > .0:
		lerp_progress -= delta * TRANSITION_SPEED
		modulate.a = lerp(TRANSITION_BOUNDS.y, TRANSITION_BOUNDS.x, lerp_progress)
	else:
		current_transition_is_in_progress = false
		if finish_func != null:
			finish_func.call_func()
