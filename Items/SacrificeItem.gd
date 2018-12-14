extends Node2D

var rotation_speed = -1.0 # How quickly should falling item rotate.
var up_speed = -.7 # At first item must fly a bit up, before falling down.
var fall_speed_growth = 1.0 # How fast to fall over time.
var time_spent = 0 # To count time correctly even if the game was paused.

const LIFE_DURATION = 8.0 # When this object should be freed.
const GRAVITY = Vector2(100.0, 200.0) # How fast for items to fall.
const ROTATION_SPEED_GROWTH = .01 # How fast the rotation becomes faster.
const FALL_SPEED_GROWTH_SPEED = .2 # How quickly to increase the fall speed.

func _ready():
	scale = Vector2()

func _process(delta):
	fall_speed_growth += FALL_SPEED_GROWTH_SPEED
	position.y += GRAVITY.y * delta * up_speed * fall_speed_growth
	up_speed = lerp(up_speed, 1.0, delta)
	time_spent += delta
	if time_spent > LIFE_DURATION:
		free_on_death()
	rotation_speed -= ROTATION_SPEED_GROWTH
	rotation += delta * rotation_speed
	scale.x = lerp(scale.x, 1.0, delta)
	scale.y = lerp(scale.y, 1.0, delta)

func free_on_death():
	queue_free()
