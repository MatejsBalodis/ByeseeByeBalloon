extends Button

var player = null # To inform player about the item.
var item_index = 1 # To be able to inform player about, which item was chosen.

func _on_UpItem_pressed():
	player.manage_up_item_event(item_index)
