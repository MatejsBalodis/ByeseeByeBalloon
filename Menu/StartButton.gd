extends Button

func _on_StartButton_pressed():
	Global.current_level_index = 0
	Global.total_score = 0
	Global.transition_to_scene("res://Story/Story.tscn")
