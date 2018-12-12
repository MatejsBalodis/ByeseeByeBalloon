extends TextureButton

var player = null # To inform player about the item.
var item_index = 1 # To be able to inform player about, which item was chosen.
var must_fall = false # To know, when to fall and dissapear.
var up_force = Vector2(1.0, -.5) # At first fly a bit up and then down.
var item_position_on_button_press = Vector2() # To detect whether there was a drag.
var item_is_pressed = false # To get the press position just once.
var gravity_increase_speed = .0 # How much to increase to fall speed.

onready var item_selection_bar = get_parent().get_parent() # For speed and convenience.
onready var original_size = self.rect_size # To perform relative changes.
onready var original_position = self.rect_position # To perform relative changes.
onready var VALUE_LABEL = get_child(0) # For speed and convenience.

const GRAVITY = Vector2(-20.0, 1000.0) # How quickly are the buttons falling.
const MAX_ACCEPT_DISTANCE = 25.0 # If the item selection bar has moved more than this, don't accept item.
const BUTTON_HOVER_CHANGE = 10.0 # How much the size and position must change.
const GRAVITY_INCREASE_SPEED_STEP = .05 # How quickly to increase fall speed.
const VALUE_LABEL_ROTATION_SPEED = 20.0 # To avoid having magic numbers.

func _on_UpItem_button_down():
	if !item_is_pressed:
		item_position_on_button_press = item_selection_bar.rect_position
		item_is_pressed = true

func _on_UpItem_button_up():
	if !must_fall:
		item_is_pressed = false
		if item_position_on_button_press.distance_squared_to(item_selection_bar.rect_position) < MAX_ACCEPT_DISTANCE && !player.item_drop_pending:
			player.start_up_item_event(item_index)
			must_fall = true

func _physics_process(delta):
	if must_fall:
		up_force.y = lerp(up_force.y, 1.0, delta)
		var position_change_step = delta * GRAVITY * up_force * gravity_increase_speed # For speed and convenience.
		rect_position += position_change_step
		VALUE_LABEL.rect_position -= position_change_step
		VALUE_LABEL.rect_rotation += delta * VALUE_LABEL_ROTATION_SPEED
		gravity_increase_speed += GRAVITY_INCREASE_SPEED_STEP


func _on_UpItem_mouse_entered():
	if !must_fall:
		rect_size = Vector2(original_size.x + BUTTON_HOVER_CHANGE, original_size.y + BUTTON_HOVER_CHANGE)
		rect_position = Vector2(original_position.x - BUTTON_HOVER_CHANGE * .5, original_position.y - BUTTON_HOVER_CHANGE * .5)

func _on_UpItem_mouse_exited():
	if !must_fall:
		rect_size = original_size
		rect_position = original_position
