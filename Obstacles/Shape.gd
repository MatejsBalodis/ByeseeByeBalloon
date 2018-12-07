extends Sprite

const BLINK_PHASE = .0075 # To avoid magic numbers.
const BLINK_AMPLITUDE = .85 # To avoid magic numbers.

func _ready():
	modulate.g = .0
	modulate.b = .5

func _process(delta):
	var current_modulate_value = sin(OS.get_ticks_msec() * BLINK_PHASE) * BLINK_AMPLITUDE # To save resources.
	modulate.a = current_modulate_value
	modulate.r = current_modulate_value
