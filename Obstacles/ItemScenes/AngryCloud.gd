extends Sprite

onready var original_position_y = self.position.y # To move relative to this altitude.

const PHASE = .001 # How rapidly are clouds moving up and down.
const AMPLITUDE = 10.0 # How high and low to float.

func _process(delta):
	position.y = original_position_y + sin(OS.get_ticks_msec() * PHASE) * AMPLITUDE
