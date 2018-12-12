extends Sprite

var threshold_bound = 100.0 # How high can balloon rise and fall.
var each_float_step_start_time = .0 # Each float step start time.
var float_direction = 1.0 # Where to fly up or down.
var current_float_goal_position = .0 # Where to float in this float step.
var lerp_speed = 20.0 # How quickly to move up and down.

onready var original_reference_position = self.position.y # Reference for relative movement.

func reset():
	pass

func _ready():
	choose_start_state()

func choose_start_state():
	float_direction = -float_direction
	current_float_goal_position = (randf() * threshold_bound * float_direction) + original_reference_position

func _process(delta):
	if abs(abs(position.y) - abs(original_reference_position)) > abs(abs(position.y) - abs(current_float_goal_position)):
		choose_start_state()
	else:
		position.y += float_direction * lerp_speed * delta
