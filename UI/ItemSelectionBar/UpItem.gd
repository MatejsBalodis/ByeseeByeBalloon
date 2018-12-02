extends Button

var player = null # To inform player about the item.
var item_index = 1 # To be able to inform player about, which item was chosen.
const GRAVITY = Vector2(-20.0, 1000.0) # How quickly are the buttons falling.
var must_fall = false # To know, when to fall and dissapear.
var up_force = Vector2(1.0, -.5) # At first fly a bit up and then down.

func _on_UpItem_pressed():
	player.manage_up_item_event(item_index)
	must_fall = true

func _process(delta):
	if must_fall:
		up_force.y = lerp(up_force.y, 1.0, delta)
		rect_position += delta * GRAVITY * up_force
