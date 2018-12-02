extends Control

onready var player = get_parent().get_parent().get_node("CharacterLayer").get_node("MainCharacter") # For speed and convenience.
onready var player_camera = player.get_node("Camera2D") # For speed and convenience.
export (PackedScene) var selection_bar_item # To instance the selection bar item.
export var level_selection_bars = [] # Assign items for each level.
const MARGIN_BETWEEN_BUTTONS = 20 # Have a bit of margin between the selection bar items.
const PUSH_DOWN_DISTANCE = 30 # Buttons should be closer to the bottom of the screen.
var selection_bar_drag_height = .2 # To know, where to allow the drag.
var old_mouse_position = Vector2() # To determine the direction of mouse movement.
var current_x_offset = MARGIN_BETWEEN_BUTTONS # To place buttons one by another.

func _ready():
	for i in range(0, level_selection_bars[Global.current_level_index].size()):
		level_selection_bars[Global.current_level_index][i][0] = selection_bar_item.instance()
		var up_item = level_selection_bars[Global.current_level_index][i][0].get_node("UpItem") # For speed and convenience.
		up_item.icon = player.up_items[i + 1][3]
		up_item.item_index = i + 1
		up_item.player = player
		add_child(level_selection_bars[Global.current_level_index][i][0])
		level_selection_bars[Global.current_level_index][i][0].rect_position.x = current_x_offset
		level_selection_bars[Global.current_level_index][i][0].rect_position.y -= level_selection_bars[Global.current_level_index][0][0].texture.get_size().y - PUSH_DOWN_DISTANCE
		current_x_offset += level_selection_bars[Global.current_level_index][i][0].texture.get_size().x + MARGIN_BETWEEN_BUTTONS

var return_speed = 5.0 # How quickly to return the bar to default offset.
onready var drag_is_active = false # To disable drag only, when mouse is released.

func _process(delta):
	var relative_mouse_position = player_camera.position + get_viewport().get_mouse_position() # For speed and convenience.
	if relative_mouse_position.y > OS.window_size.y - OS.window_size.y * selection_bar_drag_height:
		if Input.is_action_pressed("left_mouse_button"):
			drag_is_active = true
	if !Input.is_action_pressed("left_mouse_button"):
		drag_is_active = false
		if rect_position.x > .0:
			rect_position.x = lerp(rect_position.x, .0, delta * return_speed)
		elif rect_position.x < -(current_x_offset - OS.window_size.x):
			rect_position.x = lerp(rect_position.x, -(current_x_offset - OS.window_size.x), delta * return_speed)
	if drag_is_active:
		rect_position.x += (relative_mouse_position.x - old_mouse_position.x) * (1.0 - (1.0 / (OS.window_size.x / clamp(rect_position.x, 1.0, OS.window_size.x))))
	old_mouse_position = relative_mouse_position
