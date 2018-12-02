extends Node2D

onready var	restart_button = get_parent().get_parent().get_node("GUILayer").get_node("RestartButton") # For speed and convenience.
onready var	game_over_text = get_parent().get_parent().get_node("GUILayer").get_node("GameOverText") # For speed and convenience.
onready var background = get_parent().get_parent().get_node("Level") # For speed and convenience.
onready var actual_mover = get_node("ActualMover") # For speed and convenience.
export var gravities = [] # At what rate objects fall.
export var forward_velocities = [] # At what speed in which direction to move.
export var up_items = [] # Items must have various weights and prices.
export var follow_speed = 5 # How tightly to follow the actual mover.
var current_forward_velocity_index = 1 # Manage only one specific forward velocity at once.
var current_gravity_index = 1 # Manage only one specific gravity at once.
var current_up_item_index = 0 # Manage only one specific up item at once.
const TOP_THRESHOLD = 20.0 # How high can the balloon fly.
const BOTTOM_THRESHOLD = 100.0 # How low can balloon fall.
onready var camera = get_node("Camera2D") # For speed and convenience.

func _ready():
	reset()

func reset():
	actual_mover.position = Vector2(OS.window_size.x * .5, .0)
	position = Vector2(OS.window_size.x * .5, .0)
	get_parent().transform.origin.x = -camera.get_global_transform().origin.x + OS.window_size.x * .5
	#get_parent().transform.origin.y = -camera.get_global_transform().origin.y + OS.window_size.y * .5
	current_gravity_index = 1
	current_forward_velocity_index = 1
	Global.game_over_is_active = false
	restart_button.visible = false
	game_over_text.visible = false

func _process(delta):
	position.x = lerp(position.x, actual_mover.position.x, delta * follow_speed)
	position.y = lerp(position.y, actual_mover.position.y, delta * follow_speed)
	get_parent().transform.origin.x = -camera.get_global_transform().origin.x + OS.window_size.x * .5

func _physics_process(delta):
	actual_mover.position += delta * (gravities[current_gravity_index] - (up_items[current_up_item_index] if position.y > TOP_THRESHOLD else Vector2(.0, .0)) + forward_velocities[current_forward_velocity_index])
	if position.y > OS.window_size.y - BOTTOM_THRESHOLD && !Global.game_over_is_active:
		initiate_game_over()

func initiate_game_over():
	game_over_text.visible = true
	restart_button.visible = true
	current_gravity_index = 0
	current_forward_velocity_index = 0
	Global.game_over_is_active = true

func _input(event):
	if Input.is_action_pressed("ui_up"):
		current_up_item_index = 1
	else:
		current_up_item_index = 0
