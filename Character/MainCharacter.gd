extends Node2D

onready var music_manager = get_parent().get_parent().get_node("MusicManager") # For speed and convenience.
onready var gui_layer = get_parent().get_parent().get_node("GUILayer") # For speed and convenience.
onready var sacrifice_item_layer = get_parent().get_node("SacrificeItemWrapper") # For speed and convenience.
onready var game_over_wrapper = gui_layer.get_node("GameOverWrapper") # For speed and convenience.
onready var	game_over_restart_button = game_over_wrapper.get_node("GameOverRestartButton") # For speed and convenience.
onready var	game_over_menu_button = game_over_wrapper.get_node("GameOverMenuButton") # For speed and convenience.
onready var	next_level_button = game_over_wrapper.get_node("NextLevelButton") # For speed and convenience.
onready var	game_over_text = game_over_wrapper.get_node("GameOverText") # For speed and convenience.
onready var	level_complete_text = game_over_wrapper.get_node("LevelCompleteText") # For speed and convenience.
onready var selection_item_bar = gui_layer.get_node("ItemSelectionBar") # For speed and convenience.
onready var actual_mover = get_parent().get_node("ActualMover") # For speed and convenience.
onready var game_over_audio_stream_player = game_over_wrapper.get_node("GameOverAudioStreamPlayer") # For speed and convenience.
onready var level_complete_audio_stream = load("res://Audio/Music/Victory-ogg-converted.ogg") # To load level complete music.
onready var game_over_audio_stream = load("res://Audio/Music/Gameover-ogg-converted.ogg") # To load game over music.
onready var score_background = game_over_wrapper.get_node("ScoreBackground") # For speed and convenience.
onready var camera = get_node("Camera2D") # For speed and convenience.
onready var balloon_indicator = gui_layer.get_node("ProgressBar").get_node("Balloon") # For speed and convenience.
onready var balloon_indicator_finish = balloon_indicator.get_parent().get_node("Finish") # For speed and convenience.
onready var texture_progress_bar = gui_layer.get_node("ProgressBar").get_node("TextureProgress") # For speed and convenience.
onready var animation_blend_tree = get_node("Body").get_node("MainCharacterAnimations").get_node("AnimationTreePlayer") # To save resources.
onready var face_animator = get_node("Body").get_node("MainCharacterAnimations").get_node("Head").get_node("Head").get_node("MainCharacterFace").get_node("AnimationPlayer") # To save resources.
onready var body_animator = get_node("Body").get_node("MainCharacterAnimations").get_node("AnimationPlayer") # To save resources.
onready var main_character_audio_stream_player = get_node("MainCharacterAudioStreamPlayer") # For speed and convenience.
onready var original_game_over_stream_player_volume_db = game_over_audio_stream_player.volume_db # To know, where to reset the volume.
onready var music_manager_audio_stream_player = music_manager.get_node("AudioStreamPlayer") # For speed and convenience.
onready var original_music_manager_volume_db = music_manager_audio_stream_player.volume_db # To know, where to reset the volume.
onready var original_next_level_button_style_texture = next_level_button.get("custom_styles/hover").texture # To know, where to reset the texture.
# These have to be reset on level change.
onready var finish_line = get_parent().get_parent().get_node("Level").get_node("FinishLine/ParallaxLayer/FinishLine") # For speed and convenience.
# End These have to be reset on level change.

var facial_animations = ["AngryFace", "CarefulFace", "CryFace", "DeadFace", "DisappointedFace", "Idle"] # For speed and convenience.
var current_facial_animation_index = -1 # To save resources, to know, when to switch to another animation.
var forbid_changing_facial_animation = false # Animation switching sometime must be forbidden, until some descrete events happen.
var obstacle_collision_is_active = false # To act appropriately while collision is active.
var current_forward_velocity_index = 0 # Manage only one specific forward velocity at once.
var current_gravity_index = 0 # Manage only one specific gravity at once.
var current_up_item_index = 0 # Manage only one specific up item at once.
var current_up_force = Vector2() # Combine all item up force in a single value.
var velocity = Vector2() # To tell where the object is moving.
var display_score = 0 # For speed and convenience, the score that is displayed.
var current_level_score = 0 # To show the player score on game over.
var start_position_x = .0 # To know, where to compare start from.
var the_whole_level_distance = 0 # For speed and convenience.
var level_end_velocity_coefficient = 1.0 # To stop the level movement on level stop.
var item_spawn_offset = Vector2(-25.0, 100.0) # Items must spawn from the basket.
var current_drop_animation_length = 0 # To avoid having magic numbers.
var item_drop_pending = false # To allow only one drop at a time and drop item nicely after the drop animation.
var item_drop_start_time = 0 # To play drop animation for a certain amount of time.
var float_dead = .0 # To control the full character animation tree and be able to lerp between states in a scope outside the function.
var float_drop = .0 # To control the full character animation tree and be able to lerp between states in a scope outside the function.
var decline_death = .0 # To control the full character animation tree and be able to lerp between states in a scope outside the function.
var incline_decline = .0 # To control the full character animation tree and be able to lerp between states in a scope outside the function.
var death_levelcomplete = .0 # To control the full character animation tree and be able to lerp between states in a scope outside the function.
var level_end_delta_volume_lerp_progress = .0 # To have a tight control over the lerping.

export (Texture) var victory_button_texture = null # Use this texture to turn next level button into victory button.
export var gravities = [] # At what rate objects fall.
export var forward_velocities = [] # At what speed in which direction to move.
export var up_items = [] # Items must have various weights and prices.
export var follow_speed = 2.0 # How tightly to follow the actual mover.
export (PackedScene) var item_template # Instance preset sacrifice item.

const DEATH_ANIMATION_SPEED = 5.0 # How quickly to transition to death animation.
const LEGS_UP_Y_THRESHOLD = .45 # How close to the bottom of the level character starts to rise his legs.
const ACTUAL_ANIMATION_RESET = 600 # Drop the item quicker than the animation end.
const PHYSICS_VELOCITY_QOEFFICIENT = 50.0 # A handle to easy set the velocity amplitude.
const BALLOON_PROGRESS_LERP_SPEED = 1.0 # To avoid using magic numbers.
const BALLOON_PROGRESS_LERP_RETURN_SPEED = 5.0 # To avoid using magic numbers.
const SCORE_LERP_SPEED = 5.0 # How quickly to lerp to the score.
const DROP_ANIMATION_TRANSITION_SPEED = 5.0 # How quickly to enter the drop animation.
const MAX_FORCE = 1000.0 # Force cannot become stronger than this.
const INITIAL_BALLOON_PROGRESS_OFFSET = 60.0 # To have the progress balloon nicely placed at the beginning.
const TOP_THRESHOLD = 100.0 # How high can the balloon fly.
const BOTTOM_THRESHOLD = .2 # How low can balloon fall.
const DEFAULT_DROP_PAUSE = 500 # Don't allow to drop items more frequently than this in any case.
const NON_AUDIBLE_VOLUME_DB = -80.0 # Consider this to be quiet enough to be considered non audible.

func _ready():
	level_complete_audio_stream.set_loop(false)
	game_over_audio_stream.set_loop(false)
	reset()
	balloon_indicator.rect_position.x = INITIAL_BALLOON_PROGRESS_OFFSET

	gui_layer = null
	game_over_wrapper = null

	Global.set_custom_button_style_texture(next_level_button, original_next_level_button_style_texture)

func reset():
	finish_line = get_parent().get_parent().get_node("Level").get_node("FinishLine/ParallaxLayer/FinishLine")
	actual_mover.position = Vector2(get_viewport().size.x * .5, 80.0)
	position = actual_mover.position
	start_position_x = actual_mover.position.x
	the_whole_level_distance = finish_line.position.x - start_position_x
	get_parent().transform.origin.x = -camera.get_global_transform().origin.x + get_viewport().size.x * .5
	#get_parent().transform.origin.y = -camera.get_global_transform().origin.y + get_viewport().size.y * .5
	if Global.current_level_stop_state != Global.Level_stop_states.TRANSITION_IN:
		Global.current_level_stop_state = Global.Level_stop_states.NONE
	game_over_restart_button.visible = false
	game_over_menu_button.visible = false
	#next_level_button.visible = false
	game_over_text.visible = false
	level_complete_text.visible = false
	current_up_force = Vector2()
	current_up_item_index = 0
	level_end_velocity_coefficient = 1.0
	score_background.visible = false
	display_score = 0
	current_level_score = 0
	for i in range(0, up_items[Global.current_level_index].size()):
		current_level_score += up_items[Global.current_level_index][i][2]

	selection_item_bar.regenerate_items()

	game_over_audio_stream_player.stop()
	music_manager_audio_stream_player.play()
	main_character_audio_stream_player.stop()

	current_facial_animation_index = -1
	forbid_changing_facial_animation = false
	set_facial_animation(5)

	obstacle_collision_is_active = false

	item_drop_start_time = 0
	item_drop_pending = false
	current_drop_animation_length = 0

	level_end_delta_volume_lerp_progress = .0

func _process(delta):
	if (weakref(finish_line)).get_ref():
		var tmp_lerp_speed = delta * follow_speed # For speed and convenience.
		position.x = lerp(position.x, actual_mover.position.x, tmp_lerp_speed)
		position.y = lerp(position.y, actual_mover.position.y, tmp_lerp_speed)
		get_parent().transform.origin.x = lerp(get_parent().transform.origin.x, -camera.get_global_transform().origin.x + get_viewport().size.x * .5, tmp_lerp_speed)

		var tmp_force_diminish_speed = delta * 10.0 # For speed and convenience.
		current_up_force.x = max(current_up_force.x - tmp_force_diminish_speed, .0)
		current_up_force.y = max(current_up_force.y - tmp_force_diminish_speed, .0)

		manage_animation(delta)

		var new_progress_position_x = INITIAL_BALLOON_PROGRESS_OFFSET + ((texture_progress_bar.rect_size.x - INITIAL_BALLOON_PROGRESS_OFFSET) * texture_progress_bar.rect_scale.x * (1.0 - (finish_line.position.x - position.x) / the_whole_level_distance)) # For speed and convenience.
		texture_progress_bar.max_value = texture_progress_bar.rect_size.x * texture_progress_bar.rect_scale.x
		balloon_indicator.rect_position.x = min(lerp(balloon_indicator.rect_position.x, new_progress_position_x, delta * (BALLOON_PROGRESS_LERP_SPEED if balloon_indicator.rect_position.x < new_progress_position_x else BALLOON_PROGRESS_LERP_RETURN_SPEED)), balloon_indicator_finish.rect_position.x - INITIAL_BALLOON_PROGRESS_OFFSET)
		texture_progress_bar.value = balloon_indicator.rect_position.x

func initiate_level_end(level_stop_state):
	if Global.current_level_index > next_level_button.level_scenes.size() - 2:
		Global.set_custom_button_style_texture(next_level_button, victory_button_texture)
		next_level_button.visible = false
	game_over_restart_button.visible = true
	game_over_menu_button.visible = true
	next_level_button.visible = true
	game_over_restart_button.visible = true
	level_end_velocity_coefficient = .0
	Global.total_score += current_level_score
	game_over_audio_stream_player.play()

func manage_level_end_audio_transition(delta):
	level_end_delta_volume_lerp_progress = min(level_end_delta_volume_lerp_progress + delta, 1.0)
	music_manager_audio_stream_player.volume_db = lerp(original_music_manager_volume_db, NON_AUDIBLE_VOLUME_DB, level_end_delta_volume_lerp_progress)
	if level_end_delta_volume_lerp_progress > 1.0 - Global.APPROXIMATION_FLOAT:
		music_manager_audio_stream_player.stop()
	game_over_audio_stream_player.volume_db = lerp(NON_AUDIBLE_VOLUME_DB, original_game_over_stream_player_volume_db, level_end_delta_volume_lerp_progress)

func manage_level_complete_state(delta):
	display_score = lerp(display_score, current_level_score, delta * SCORE_LERP_SPEED)
	var int_display_score = str(current_level_score if display_score > current_level_score - 2 else int(display_score))
	score_background.get_node("Score").text = int_display_score
	score_background.get_node("Shadow").text = int_display_score

func _physics_process(delta):
	if (weakref(finish_line)).get_ref():
		velocity = PHYSICS_VELOCITY_QOEFFICIENT * delta * (gravities[current_gravity_index] - (current_up_force if position.y > TOP_THRESHOLD else Vector2()) + forward_velocities[current_forward_velocity_index]) * level_end_velocity_coefficient
		actual_mover.move_and_slide(velocity)
		if position.y > get_viewport().size.y - get_viewport().size.y * BOTTOM_THRESHOLD:
			if Global.current_level_stop_state == Global.Level_stop_states.NONE:
				current_level_score = 0
				game_over_text.visible = true
				Global.current_level_stop_state = Global.Level_stop_states.GAME_OVER
				game_over_audio_stream_player.stream = game_over_audio_stream
				main_character_audio_stream_player.play_die_sfx()
				initiate_level_end(Global.Level_stop_states.GAME_OVER)
			manage_level_end_audio_transition(delta)
		elif position.x > finish_line.position.x:
			if Global.current_level_stop_state == Global.Level_stop_states.NONE:
				score_background.visible = true
				level_complete_text.visible = true
				Global.current_level_stop_state = Global.Level_stop_states.LEVEL_COMPLETE
				game_over_audio_stream_player.stream = level_complete_audio_stream
				main_character_audio_stream_player.play_win_sfx()
				initiate_level_end(Global.Level_stop_states.LEVEL_COMPLETE)
			manage_level_end_audio_transition(delta)
			manage_level_complete_state(delta)

func start_up_item_event(item_index):
	forbid_changing_facial_animation = false
	set_facial_animation(1)
	current_up_item_index = item_index
	item_drop_start_time = OS.get_ticks_msec()
	current_drop_animation_length = animation_blend_tree.animation_node_get_animation("drop2").length * ACTUAL_ANIMATION_RESET
	animation_blend_tree.oneshot_node_start("drop_shot")
	set_character_blend_state(.0, 1.0, .0, .0, .0, .1)
	item_drop_pending = true

func manage_up_item_event():
	var tmp_up_item = item_template.instance()
	tmp_up_item.get_node("Sprite").texture = up_items[Global.current_level_index][current_up_item_index][1]
	sacrifice_item_layer.add_child(tmp_up_item)
	tmp_up_item.position = position + item_spawn_offset
	current_up_force += up_items[Global.current_level_index][current_up_item_index][0] * .1
	current_level_score -= up_items[Global.current_level_index][current_up_item_index][2]
	if current_up_force < up_items[Global.current_level_index][current_up_item_index][0]:
		current_up_force = up_items[Global.current_level_index][current_up_item_index][0] + up_items[Global.current_level_index][current_up_item_index][0] * .1
	main_character_audio_stream_player.play_ascend_sfx()

func set_character_blend_state(float_dead_goal, float_drop_goal, decline_death_goal, incline_decline_goal, death_levelcomplete_goal, new_state_reach_lerp_speed):
	float_dead = lerp(float_dead, float_dead_goal, new_state_reach_lerp_speed)
	float_drop = lerp(float_drop, float_drop_goal, new_state_reach_lerp_speed)
	decline_death = lerp(decline_death, decline_death_goal, new_state_reach_lerp_speed)
	incline_decline = lerp(incline_decline, incline_decline_goal, new_state_reach_lerp_speed)
	death_levelcomplete = lerp(death_levelcomplete, death_levelcomplete_goal, new_state_reach_lerp_speed)
	animation_blend_tree.blend2_node_set_amount("float_dead", float_dead)
	animation_blend_tree.blend2_node_set_amount("float_drop", float_drop)
	animation_blend_tree.blend2_node_set_amount("decline_death", decline_death)
	animation_blend_tree.blend2_node_set_amount("incline_decline", incline_decline)
	animation_blend_tree.blend2_node_set_amount("death_levelcomplete", death_levelcomplete)

func set_descrete_facial_animation(index, state):
	set_facial_animation(index)
	forbid_changing_facial_animation = state

func set_facial_animation(new_animation_index):
	if current_facial_animation_index != new_animation_index && !forbid_changing_facial_animation:
		current_facial_animation_index = new_animation_index
		face_animator.seek(0.0, true)
		face_animator.current_animation = facial_animations[current_facial_animation_index]
		face_animator.play()
		face_animator.playback_speed = 1.0

func manage_animation(delta):
	if Global.current_level_stop_state == Global.Level_stop_states.GAME_OVER:
		forbid_changing_facial_animation = false
		set_character_blend_state(1.0, .0, 1.0, .0, .0, delta * DEATH_ANIMATION_SPEED)
		set_facial_animation(3)
	elif Global.current_level_stop_state == Global.Level_stop_states.LEVEL_COMPLETE:
		forbid_changing_facial_animation = false
		set_character_blend_state(1.0, .0, 1.0, .0, 1.0, delta * DEATH_ANIMATION_SPEED)
		set_facial_animation(5)
	elif OS.get_ticks_msec() - item_drop_start_time < current_drop_animation_length:
		set_character_blend_state(.0, 1.0, .0, .0, .0, delta * DROP_ANIMATION_TRANSITION_SPEED)
	elif item_drop_pending:
		item_drop_pending = false
		manage_up_item_event()
	elif position.y > get_viewport().size.y - get_viewport().size.y * LEGS_UP_Y_THRESHOLD:
		set_character_blend_state(1.0, .0, .0, .0, .0, delta)
		set_facial_animation(5)
	elif velocity.y > .0:
		set_character_blend_state(.0, .0, .0, 1.0, .0, delta)
		set_facial_animation(5)
	elif velocity.y < .0:
		set_character_blend_state(.0, .0, .0, .0, .0, delta)
		set_facial_animation(5)
