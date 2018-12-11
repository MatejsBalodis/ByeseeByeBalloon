extends Button

export var level_scenes = [] # To load appropriate levels.
onready var world_wrapper = get_parent().get_parent().get_parent() # For speed and convenience.
onready var character_layer = world_wrapper.get_node("CharacterLayer") # For speed and convenience.
onready var current_level_scene = world_wrapper.get_node("Level")  # Use this level currently.
onready var current_obstacle_wrapper =character_layer.get_node("ObstacleWrapper") # Use this obstacle wrapper currently.
onready var main_character = character_layer.get_node("MainCharacter") # For speed and convenience.

func _on_NextLevelButton_pressed():
	current_level_scene.name = "level_for_deletion"
	current_level_scene.queue_free()
	current_obstacle_wrapper.name = "obstacle_wrapper_for_deletion"
	current_obstacle_wrapper.queue_free()
	Global.current_level_index += 1
	current_level_scene = level_scenes[Global.current_level_index][0].instance()
	current_level_scene.name = "Level"
	world_wrapper.add_child(current_level_scene)
	current_obstacle_wrapper = level_scenes[Global.current_level_index][1].instance()
	current_obstacle_wrapper.name = "ObstacleWrapper"
	character_layer.add_child(current_obstacle_wrapper)
	main_character.reset()
