extends Node2D

onready var main_character_camera = get_parent().get_node("MainCharacter").get_node("Camera2D") # For speed and convenience.

func _physics_process(delta):
	position.y = main_character_camera.original_y_position - main_character_camera.get_camera_position().y
