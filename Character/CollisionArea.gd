extends Area2D

onready var main_character = get_parent().get_parent().get_node("MainCharacter") # For speed and convenience.
var current_colliding_obstacle = null # For speed and convenience.
const BLINK_PHASE = .01 # How quickly to blink obstacle on collision.

func _on_CollisionArea_body_entered(body):
	current_colliding_obstacle = body.get_parent()
	current_alpha = 1.0
	obstacle_blink_start_time = OS.get_ticks_msec()
	main_character.obstacle_collision_is_active = true
	main_character.current_up_force = Vector2()
	main_character.set_descrete_facial_animation(2, true)
	main_character.get_node("MainCharacterAudioStreamPlayer").play_hit_sfx()

func _on_CollisionArea_body_exited(body):
	main_character.obstacle_collision_is_active = false
	main_character.set_descrete_facial_animation(5, false)

var current_alpha = 1.0 # To make calculations easier.
const BLINK_BOUNDS = Vector2(.25, 1.0) # To avoid having magic numbers. Object should not become completely transparent, when blinking.
const RETURN_OPACITY_SPEED = 10.0 # To avoid having magic numbers.
var obstacle_blink_start_time = 0 # To determine for how long has blinking been happening.
const BLINK_PAUSE = 500 # For how long to blink.
const SHAKE_ROTATION_COEFFICIENT = .2 # How strongly to shake rotate main character on collision.
const MAX_ROTATION = 70.0 # Limit how hard can the player be rotated on collision.

func set_blink_color(blink_parameter):
	current_colliding_obstacle.modulate.a = blink_parameter
	current_colliding_obstacle.modulate.r = blink_parameter

func _process(delta):
	if current_colliding_obstacle != null:
		if OS.get_ticks_msec() - obstacle_blink_start_time < BLINK_PAUSE:
			current_alpha = sin(OS.get_ticks_msec() * BLINK_PHASE)
			set_blink_color(BLINK_BOUNDS.x + (current_alpha if current_alpha > .0 else -current_alpha))
			var new_rotation = current_alpha * SHAKE_ROTATION_COEFFICIENT * (BLINK_PAUSE - (OS.get_ticks_msec() - obstacle_blink_start_time)) * BLINK_PHASE # For speed and convenience.
			if abs(new_rotation) < MAX_ROTATION:
				main_character.rotation = new_rotation
		else:
			set_blink_color(current_colliding_obstacle.modulate.a + delta * RETURN_OPACITY_SPEED)
			main_character.rotation = lerp(main_character.rotation, .0, current_colliding_obstacle.modulate.a)
			if current_colliding_obstacle.modulate.a > 1.0 - Global.APPROXIMATION_FLOAT:
				set_blink_color(1.0)
				main_character.rotation = .0
				current_colliding_obstacle = null

