extends Button

export var skip_index = 0 # To which scene to go from skip button.
export var skip_paths = ["res://World.tscn", "res://Victory.tscn"] # All the possible levels to go from the skip button.

func _on_SkipButton_pressed():
	Global.transition_to_scene(skip_paths[skip_index])
