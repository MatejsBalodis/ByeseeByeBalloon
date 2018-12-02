extends Node2D

var drop_start_time = 0 # To measure to drop time.
var life_duration = 8000 # When this object should be freed.
var gravity = Vector2(100.0, 200.0) # How fast for items to fall.
var rotation_speed = -1.0 # How quickly should falling item rotate.
var rotation_speed_growth = .01 # How fast the rotation becomes faster.

func _ready():
	drop_start_time = OS.get_ticks_msec()

func _process(delta):
	position.y += gravity.y * delta
	if OS.get_ticks_msec() - drop_start_time > life_duration:
		free_on_death()
	rotation_speed -= rotation_speed_growth
	rotation += delta * rotation_speed

func free_on_death():
	queue_free()
