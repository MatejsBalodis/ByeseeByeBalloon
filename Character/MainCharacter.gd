extends Node2D

onready var gui_layer = get_parent().get_parent().get_node("GUILayer") # For speed and convenience.
onready var sacrifice_item_layer = get_parent().get_node("SacrificeItemWrapper") # For speed and convenience.
onready var	restart_button = gui_layer.get_node("GameOverWrapper").get_node("RestartButton") # For speed and convenience.
onready var	game_over_text = gui_layer.get_node("GameOverWrapper").get_node("GameOverText") # For speed and convenience.
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

func _ready():
	reset()

func reset():
	actual_mover.position = Vector2(get_viewport().size.x * .5, .0)
	position = Vector2(get_viewport().size.x * .5, .0)
	get_parent().transform.origin.x = -camera.get_global_transform().origin.x + get_viewport().size.x * .5
	#get_parent().transform.origin.y = -camera.get_global_transform().origin.y + get_viewport().size.y * .5
	current_gravity_index = 1
	current_forward_velocity_index = 1
	Global.game_over_is_active = false
	restart_button.visible = false
	game_over_text.visible = false
	current_up_force = Vector2()
	current_up_item_index = 0

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

func _physics_process(delta):
	velocity = delta * (gravities[current_gravity_index] - (current_up_force if position.y > TOP_THRESHOLD else Vector2()) + forward_velocities[current_forward_velocity_index])
	actual_mover.position += velocity
	if position.y > get_viewport().size.y - get_viewport().size.y * BOTTOM_THRESHOLD && !Global.game_over_is_active:
		initiate_game_over()

func initiate_game_over():
	game_over_text.visible = true
	restart_button.visible = true
	current_gravity_index = 0
	current_forward_velocity_index = 0
	Global.game_over_is_active = true

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
	if current_up_force < up_items[current_up_item_index][0]:
		current_up_force = up_items[current_up_item_index][0] + up_items[current_up_item_index][0] * .1

onready var animation_blend_tree = get_node("Body").get_node("MainCharacterAnimations").get_node("AnimationTreePlayer") # To save resources.
var final_blend_amount = .0 # How much to blend towards final blend.

func manage_animation(delta):
	final_blend_amount += delta * velocity.y
	final_blend_amount = clamp(final_blend_amount, .0, 1.0)
	animation_blend_tree.blend3_node_set_amount("final_blend", final_blend_amount)
