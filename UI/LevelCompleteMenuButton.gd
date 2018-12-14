extends Button

func _on_LevelCompleteMenuButton_pressed():
	get_tree().paused = false
	Global.transition_to_scene("res://Menu/Menu.tscn")
