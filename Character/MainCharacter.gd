extends Node2D

onready var audio_manager = get_parent().get_parent().get_node("AudioManager") # For speed and convenience.
onready var gui_layer = get_parent().get_parent().get_node("GUILayer") # For speed and convenience.
onready var sacrifice_item_layer = get_parent().get_node("SacrificeItemWrapper") # For speed and convenience.
onready var game_over_wrapper = gui_layer.get_node("GameOverWrapper") # For speed and convenience.
onready var	game_over_restart_button = game_over_wrapper.get_node("GameOverRestartButton") # For speed and convenience.
onready var	game_over_menu_button = game_over_wrapper.get_node("GameOverMenuButton") # For speed and convenience.
onready var	game_over_text = game_over_wrapper.get_node("GameOverText") # For speed and convenience.
onready var	level_complete_text = game_over_wrapper.get_node("LevelCompleteText") # For speed and convenience.
onready var selection_item_bar = gui_layer.get_node("ItemSelectionBar") # For speed and convenience.
onready var background = get_parent().get_parent().get_node("Level") # For speed and convenience.
onready var actual_mover = get_node("ActualMover") # For speed and convenience.
export var gravities = [] # At what rate objects fall.
export var forward_velocities = [] # At what speed in which direction to move.
export var up_items = [] # Items must have various weights and prices.
export var follow_speed = 5 # How tightly to follow the actual mover.
var current_forward_velocity_index = 1 # Manage only one specific forward velocity at once.
var current_gravity_index = 1 # Manage only one specific gravity at once.
var current_up_item_index = 0 # Manage only one specific up item at once.
const TOP_THRESHOLD = 100.0 # How high can the balloon fly.
const BOTTOM_THRESHOLD = .2 # How low can balloon fall.
const DEFAULT_DROP_PAUSE = 500 # Don't allow to drop items more frequently than this in any case.
onready var camera = get_node("Camera2D") # For speed and convenience.
var current_up_force = Vector2() # Combine all item up force in a single value.
var velocity = Vector2() # To tell where the object is moving.
onready var finish_line = background.get_node("FinishLine/ParallaxLayer/FinishLine") # For speed and convenience.
onready var game_over_audio_stream_player = game_over_wrapper.get_node("GameOverAudioStreamPlayer") # For speed and convenience.
onready var level_complete_audio_stream = load("res://Audio/Music/Victory-ogg-converted.ogg") # To load level complete music.
onready var game_over_audio_stream = load("res://Audio/Music/Gameover-ogg-converted.ogg") # To load game over music.
onready var score_background = game_over_wrapper.get_node("ScoreBackground") # For speed and convenience.
var display_score = 0 # For speed and convenience, the score that is displayed.
onready var current_total_score = 0 # To show the player score on game over.

func _ready():
	level_complete_audio_stream.set_loop(false)
	game_over_audio_stream.set_loop(false)
	reset()

func reset():
	actual_mover.position = Vector2(get_viewport().size.x * .5, .0)
	position = Vector2(get_viewport().size.x * .5, .0)
	get_parent().transform.origin.x = -camera.get_global_transform().origin.x + get_viewport().size.x * .5
	#get_parent().transform.origin.y = -camera.get_global_transform().origin.y + get_viewport().size.y * .5
	current_gravity_index = 1
	current_forward_velocity_index = 1
	Global.game_over_is_active = false
	Global.level_complete_is_active = false
	game_over_restart_button.visible = false
	game_over_menu_button.visible = false
	game_over_text.visible = false
	level_complete_text.visible = false
	current_up_force = Vector2()
	current_up_item_index = 0
	level_complete_velocity_coefficient = 1.0
	score_background.visible = false
	display_score = 0
	current_total_score = 0
	for i in range(1, up_items.size()):
		current_total_score += up_items[i][2]

	selection_item_bar.visible = true
	selection_item_bar.regenerate_items()

	game_over_audio_stream_player.stop()
	audio_manager.get_node("AudioStreamPlayer").play()

const MAX_FORCE = 1000.0 # Force cannot become stronger than this.

func _process(delta):
	var tmp_lerp_speed = delta * follow_speed # For speed and convenience.
	position.x = lerp(position.x, actual_mover.position.x, tmp_lerp_speed)
	position.y = lerp(position.y, actual_mover.position.y, tmp_lerp_speed)
	get_parent().transform.origin.x = lerp(get_parent().transform.origin.x, -camera.get_global_transform().origin.x + get_viewport().size.x * .5, tmp_lerp_speed)

	var tmp_force_diminish_speed = delta * 10.0 # For speed and convenience.
	current_up_force.x -= tmp_force_diminish_speed
	current_up_force.x = clamp(current_up_force.x, .0, MAX_FORCE)
	current_up_force.y -= tmp_force_diminish_speed
	current_up_force.y = clamp(current_up_force.y, .0, MAX_FORCE)

	manage_animation(delta)

const SCORE_LERP_SPEED = 5.0 # How quickly to lerp to the score.

func initiate_level_complete(delta):
	display_score = lerp(display_score, current_total_score, delta * SCORE_LERP_SPEED)
	var int_display_score = str(current_total_score if display_score > current_total_score - 2 else int(display_score))
	score_background.get_node("Score").text = int_display_score
	score_background.get_node("Shadow").text = int_display_score
	if !Global.level_complete_is_active:
		selection_item_bar.visible = false
		level_complete_text.visible = true
		level_complete_velocity_coefficient = .0
		Global.level_complete_is_active = true
		game_over_restart_button.visible = true
		game_over_menu_button.visible = true
		score_background.visible = true

		audio_manager.get_node("AudioStreamPlayer").stop()
		game_over_audio_stream_player.stream = level_complete_audio_stream
		game_over_audio_stream_player.play()

func initiate_game_over(delta):
	display_score = lerp(display_score, current_total_score, delta * SCORE_LERP_SPEED)
	var int_display_score = str(current_total_score if display_score > current_total_score - 2 else int(display_score))
	score_background.get_node("Score").text = int_display_score
	score_background.get_node("Shadow").text = int_display_score
	if !Global.game_over_is_active:
		selection_item_bar.visible = false
		game_over_text.visible = true
		game_over_restart_button.visible = true
		game_over_menu_button.visible = true
		current_gravity_index = 0
		current_forward_velocity_index = 0
		Global.game_over_is_active = true
		score_background.visible = true

		audio_manager.get_node("AudioStreamPlayer").stop()
		game_over_audio_stream_player.stream = game_over_audio_stream
		game_over_audio_stream_player.play()

var level_complete_velocity_coefficient = 1.0 # To stop the level on level complete.

func _physics_process(delta):
	velocity = delta * (gravities[current_gravity_index] - (current_up_force if position.y > TOP_THRESHOLD else Vector2()) + forward_velocities[current_forward_velocity_index]) * level_complete_velocity_coefficient
	actual_mover.position += velocity
	if position.y > get_viewport().size.y - get_viewport().size.y * BOTTOM_THRESHOLD:
		initiate_game_over(delta)
	if position.x > finish_line.position.x:
		initiate_level_complete(delta)

export (PackedScene) var item_template # Instance preset sacrifice item.
var move_up_start_time = 0 # To know, for how long to fly up.
var item_spawn_offset = Vector2(-25.0, 100.0) # Items must spawn from the basket.

func manage_up_item_event(item_index):
	current_up_item_index = item_index
	var tmp_up_item = item_template.instance()
	tmp_up_item.get_node("Sprite").texture = up_items[current_up_item_index][1]
	sacrifice_item_layer.add_child(tmp_up_item)
	tmp_up_item.position = position + item_spawn_offset
	move_up_start_time = OS.get_ticks_msec()
	current_up_force += up_items[current_up_item_index][0] * .1
	current_total_score -= up_items[current_up_item_index][2]
	if current_up_force < up_items[current_up_item_index][0]:
		current_up_force = up_items[current_up_item_index][0] + up_items[current_up_item_index][0] * .1

onready var animation_blend_tree = get_node("Body").get_node("MainCharacterAnimations").get_node("AnimationTreePlayer") # To save resources.
var final_blend_amount = .0 # How much to blend towards final blend.

func manage_animation(delta):
	# final_blend_amount += delta * velocity.y
	# final_blend_amount = clamp(final_blend_amount, .0, 1.0)
	# animation_blend_tree.blend3_node_set_amount("final_blend", final_blend_amount)
	pass
