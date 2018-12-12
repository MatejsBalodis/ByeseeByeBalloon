extends TextureRect

var drag_indicator_lerp_direction = 1.0 # To increase or decrease the opacity.
var current_indicator_lerp_progress = .0 # To have a tight control over lerping.

const DRAG_INDICATOR_ALPHA_BOUNDS = Vector2(.0, 1.0) # Blink between these alphas.
const DRAG_INDICATOR_BLINK_SPEED = 2.0 # How quickly to blink.

func lerp_indicator_opacity(one_shot, lerp_direction, delta):
	if one_shot:
		drag_indicator_lerp_direction = lerp_direction
	else:
		if current_indicator_lerp_progress > 1.0 - Global.APPROXIMATION_FLOAT || current_indicator_lerp_progress < Global.APPROXIMATION_FLOAT:
			drag_indicator_lerp_direction = -drag_indicator_lerp_direction
	current_indicator_lerp_progress += delta * DRAG_INDICATOR_BLINK_SPEED * drag_indicator_lerp_direction
	current_indicator_lerp_progress = clamp(current_indicator_lerp_progress, .0, 1.0)
	modulate.a = lerp(DRAG_INDICATOR_ALPHA_BOUNDS.x, DRAG_INDICATOR_ALPHA_BOUNDS.y, current_indicator_lerp_progress)
