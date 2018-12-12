extends AudioStreamPlayer

onready var balloon_hit_obstacle_sfx = load("res://Audio/sfx/Baloon_Scared-ogg-converted.ogg") # For speed and convenience.
onready var balloon_die_obstacle_sfx = load("res://Audio/sfx/Baloon_super_sad-ogg-converted.ogg") # For speed and convenience.
onready var balloon_ascend_obstacle_sfx = load("res://Audio/sfx/Baloon_Trying_hard2-ogg-converted.ogg") # For speed and convenience.
onready var balloon_win_obstacle_sfx = load("res://Audio/sfx/Baloon_laugh1-ogg-converted.ogg") # For speed and convenience.

func _ready():
	balloon_hit_obstacle_sfx.set_loop(false)
	balloon_die_obstacle_sfx.set_loop(false)
	balloon_ascend_obstacle_sfx.set_loop(false)
	balloon_win_obstacle_sfx.set_loop(false)

func play_win_sfx():
	stop()
	stream = balloon_win_obstacle_sfx
	play()

func play_ascend_sfx():
	stop()
	stream = balloon_ascend_obstacle_sfx
	play()

func play_hit_sfx():
	stop()
	stream = balloon_hit_obstacle_sfx
	play()

func play_die_sfx():
	stop()
	stream = balloon_die_obstacle_sfx
	play()

