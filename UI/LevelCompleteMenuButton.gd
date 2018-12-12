extends Button

func _on_LevelCompleteMenuButton_pressed():
	get_tree().paused = false
	Global.goto_scene("res://Menu/Menu.tscn")
