extends Button

onready var main_character = get_parent().get_parent().get_parent().get_node("CharacterLayer").get_node("MainCharacter") # For speed and convenience.

func _on_RestartButton_pressed():
	get_tree().paused = false
	main_character.reset()
