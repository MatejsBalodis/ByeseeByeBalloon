extends Button

onready var main_character = get_parent().get_parent().get_parent().get_node("CharacterLayer").get_node("MainCharacter") # For speed and convenience.

func _on_RestartButton_pressed():
	main_character.reset()
