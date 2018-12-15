extends Control

onready var player = get_parent().get_parent().get_node("CharacterLayer").get_node("MainCharacter") # For speed and convenience.
onready var player_camera = player.get_node("Camera2D") # For speed and convenience.
onready var drag_is_active = false # To disable drag only, when mouse is released.
onready var drag_indicator_right = get_parent().get_node("DragIndicatorRight") # For speed and convenience.
onready var drag_indicator_left = get_parent().get_node("DragIndicatorLeft") # For speed and convenience.
onready var original_y_position = self.rect_position.y # To know, where to return the bottom bar after reset.

export (PackedScene) var selection_bar_item # To instance the selection bar item.
export var level_selection_bars = [] # Assign items for each level.

const MARGIN_BETWEEN_BUTTONS = 20 # Have a bit of margin between the selection bar items.
const PUSH_DOWN_DISTANCE = 30 # Buttons should be closer to the bottom of the screen.
const BAR_RETURN_CLOSE_ENOUGH_DISTANCE = 20.0 # To avoid getting lerp being stuck at the end.
const BAR_RETURN_SPEED = 3.0 # How quickly to scroll the bar back on reset.
const DANGER_THRESHOLD = .4 # How low can balloon fall.
const PLAYER_DYNAMIC_DANGER_TRANSPARENCY_HANDLE = 1.5 # How transparent to make the item background on danger.
const BAR_ALPHA_DISSAPPEAR_SPEED = 10.0 # How quickly to dissappear on game over state.
const BAR_ALPHA_APPEAR_SPEED = 3.0 # How quickly to appear on game over state.
const BAR_MOVE_IN_SPEED = 10.0 # How quickly to move in the bar after reset.
const ITEM_SHRINK_SPEED = 1000.0 # How quickly to push items together.

var old_mouse_position = Vector2() # To determine the direction of mouse movement.
var current_x_offset = MARGIN_BETWEEN_BUTTONS # To place buttons one by another.
var button_height = .0 # To detect when to drag activate drag and correctly position buttons at the bottom of the screen.
var return_on_reset = false # To forbid dragging bar with mouse and return to the initial position.
var return_lerp_progress = .0 # To have a tight control over lerping.
var player_is_in_danger = false # To save resources and check only for this variable in items.
var player_danger_alpha_coefficient = .0 # To calculate alpha dynamically based on how far in the danger zone the player is in.
var bar_shrink_items = [] # To know when and which items to remove from the bar.
var original_item_positions = [] # Change positions relative to this.
var one_item_width = .0 # For speed and convenience.

func free_memory_from_the_previous_item_set():
	for i in range(0, level_selection_bars[Global.current_level_index].size()):
		if level_selection_bars[Global.current_level_index][i][0] != null:
			level_selection_bars[Global.current_level_index][i][0].queue_free()

func regenerate_items():
	return_on_reset = true
	current_x_offset = MARGIN_BETWEEN_BUTTONS
	free_memory_from_the_previous_item_set()

	level_selection_bars.clear()
	for i in range(0, player.up_items.size()):
		level_selection_bars.append([])
		for i2 in range(0, player.up_items[i].size()):
			level_selection_bars[i].append([])
			for i3 in range(0, 2):
				level_selection_bars[i][i2].append(null)

	original_item_positions.clear()

	for i in range(0, level_selection_bars[Global.current_level_index].size()):
		level_selection_bars[Global.current_level_index][i][0] = selection_bar_item.instance()
		var up_item = level_selection_bars[Global.current_level_index][i][0].get_node("UpItem") # For speed and convenience.
		up_item.texture_hover = player.up_items[Global.current_level_index][i][3]
		up_item.texture_pressed = player.up_items[Global.current_level_index][i][3]
		up_item.texture_disabled = player.up_items[Global.current_level_index][i][3]
		up_item.texture_normal = player.up_items[Global.current_level_index][i][3]
		up_item.get_child(0).get_child(0).text = str(player.up_items[Global.current_level_index][i][2])
		up_item.item_index = i
		up_item.player = player
		add_child(level_selection_bars[Global.current_level_index][i][0])
		original_item_positions.append(current_x_offset)
		level_selection_bars[Global.current_level_index][i][0].rect_position.x = current_x_offset
		level_selection_bars[Global.current_level_index][i][0].rect_position.y -= level_selection_bars[Global.current_level_index][0][0].texture.get_size().y - PUSH_DOWN_DISTANCE
		current_x_offset += level_selection_bars[Global.current_level_index][i][0].texture.get_size().x + MARGIN_BETWEEN_BUTTONS
	button_height = level_selection_bars[Global.current_level_index][0][0].texture.get_size().y

	drag_indicator_right.current_indicator_lerp_progress = .0
	drag_indicator_left.current_indicator_lerp_progress = .0
	return_lerp_progress = .0

	bar_shrink_items.clear()

	one_item_width = original_item_positions[1] - original_item_positions[0]

func _process(delta):
	if Global.current_level_stop_state != Global.Level_stop_states.NONE:
		drag_indicator_right.lerp_indicator_opacity(true, -1.0, delta)
		drag_indicator_left.lerp_indicator_opacity(true, -1.0, delta)
	else:
		if return_on_reset:
			if return_lerp_progress > 1.0 - Global.APPROXIMATION_FLOAT:
				rect_position.x = .0
				return_on_reset = false
			else:
				return_lerp_progress = min(return_lerp_progress + delta * BAR_RETURN_SPEED, 1.0)
				rect_position.x = lerp(rect_position.x, .0, return_lerp_progress)
		else:
			var bar_width = (get_viewport().size.x if get_viewport().size.x < current_x_offset else current_x_offset) # For speed and convenience.
			var relative_mouse_position = player_camera.position + get_viewport().get_mouse_position() # For speed and convenience.
			if relative_mouse_position.y > rect_position.y - button_height:
				if rect_position.x < .0:
					drag_indicator_left.lerp_indicator_opacity(false, .0, delta)
				else:
					drag_indicator_left.lerp_indicator_opacity(true, -1.0, delta)
				if rect_position.x > -(current_x_offset - bar_width):
					drag_indicator_right.lerp_indicator_opacity(false, .0, delta)
				else:
					drag_indicator_right.lerp_indicator_opacity(true, -1.0, delta)
				if Input.is_action_pressed("left_mouse_button"):
					drag_is_active = true
					return_lerp_progress = .0
			else:
				drag_indicator_right.lerp_indicator_opacity(true, -1.0, delta)
				drag_indicator_left.lerp_indicator_opacity(true, -1.0, delta)
			if !Input.is_action_pressed("left_mouse_button"):
				drag_is_active = false
				if rect_position.x > .0:
					return_lerp_progress = min(return_lerp_progress + delta * BAR_RETURN_SPEED, 1.0)
					rect_position.x = lerp(rect_position.x, .0, return_lerp_progress)
				elif rect_position.x < -(current_x_offset - bar_width):
					return_lerp_progress = min(return_lerp_progress + delta * BAR_RETURN_SPEED, 1.0)
					rect_position.x = lerp(rect_position.x, -(current_x_offset - bar_width), return_lerp_progress)
			if drag_is_active:
				rect_position.x += (relative_mouse_position.x - old_mouse_position.x) * (1.0 - (1.0 / (bar_width / clamp(rect_position.x, 1.0, bar_width))))
			old_mouse_position = relative_mouse_position

	if Global.current_level_stop_state == Global.Level_stop_states.NONE:
		manage_bar_visibility(1.0, original_y_position, delta * BAR_ALPHA_APPEAR_SPEED, delta * BAR_MOVE_IN_SPEED)
		if player.position.y > get_viewport().size.y - get_viewport().size.y * DANGER_THRESHOLD:
			player_is_in_danger = true
			var the_danger_threshold_distance = get_viewport().size.y - get_viewport().size.y * DANGER_THRESHOLD # For speed and convenience.
			player_danger_alpha_coefficient = ((player.position.y - the_danger_threshold_distance) / the_danger_threshold_distance) * PLAYER_DYNAMIC_DANGER_TRANSPARENCY_HANDLE
		else:
			player_is_in_danger = false
	else:
		manage_bar_visibility(.0, original_y_position + get_viewport().size.y, delta * BAR_ALPHA_DISSAPPEAR_SPEED, delta)

func _physics_process(delta):
	if bar_shrink_items.size() > 0:
		var loop_range = level_selection_bars[Global.current_level_index].size() - (bar_shrink_items[0] + 1) # To know how many items to move.
		for i in range(0, loop_range):
			var bar_shrink_item = i + bar_shrink_items[0] + 1 # For speed and convenience.
			level_selection_bars[Global.current_level_index][bar_shrink_item][0].rect_position.x -= delta * ITEM_SHRINK_SPEED
			if i == 0 && level_selection_bars[Global.current_level_index][bar_shrink_item][0].rect_position.x <= level_selection_bars[Global.current_level_index][bar_shrink_item - 1][0].rect_position.x:
				for i2 in range(0, loop_range):
					bar_shrink_item = i2 + bar_shrink_items[0] + 1
					level_selection_bars[Global.current_level_index][bar_shrink_item][0].rect_position.x = original_item_positions[int(level_selection_bars[Global.current_level_index][bar_shrink_item][0].rect_position.x / one_item_width)]
				bar_shrink_items.remove(0)
				break

func manage_bar_visibility(alpha_goal, y_goal, alpha_speed, y_speed):
	modulate.a = lerp(modulate.a, alpha_goal, alpha_speed)
	rect_position.y = lerp(rect_position.y, y_goal, y_speed)

func shrink_bar(index):
	if index < level_selection_bars[Global.current_level_index].size() - 1:
		bar_shrink_items.append(index)
