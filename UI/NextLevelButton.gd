extends Button

const OUTRO_SCENE_PATH = "res://Story/StoryOutro.tscn" # To load the victory scene.

export var level_scenes = [] # To load appropriate levels.

onready var world_wrapper = get_parent().get_parent().get_parent() # For speed and convenience.
onready var character_layer = world_wrapper.get_node("CharacterLayer") # For speed and convenience.
onready var current_level_scene = world_wrapper.get_node("Level")  # Use this level currently.
onready var current_obstacle_wrapper = character_layer.get_node("ObstacleWrapper") # Use this obstacle wrapper currently.
onready var item_selection_bar = get_parent().get_parent().get_node("ItemSelectionBar") # For speed and convenience.
onready var main_character = character_layer.get_node("MainCharacter") # For speed and convenience.
onready var level_transition = get_parent().get_parent().get_node("LevelTransition") # For speed and convenience.

func _on_NextLevelButton_pressed():
	if Global.current_level_stop_state == Global.Level_stop_states.LEVEL_COMPLETE || Global.current_level_stop_state == Global.Level_stop_states.GAME_OVER:
		item_selection_bar.free_memory_from_the_previous_item_set()
		current_level_scene.name = "level_for_deletion"
		current_level_scene.queue_free()
		current_obstacle_wrapper.name = "obstacle_wrapper_for_deletion"
		current_obstacle_wrapper.queue_free()
		Global.current_level_index += 1
		Global.current_level_stop_state = Global.Level_stop_states.SWITCH_LEVEL_OUT
		level_transition.current_transition_is_in_progress = true
		if Global.current_level_index - 1 > level_scenes.size() - 1:
			Global.current_level_index = level_scenes.size() - 1
			Global.transition_to_scene(OUTRO_SCENE_PATH)
			return

func _process(delta):
	if Global.current_level_stop_state == Global.Level_stop_states.SWITCH_LEVEL_OUT && !level_transition.current_transition_is_in_progress:
		current_level_scene = level_scenes[Global.current_level_index - 1][0].instance()
		current_level_scene.name = "Level"
		world_wrapper.add_child(current_level_scene)
		current_obstacle_wrapper = level_scenes[Global.current_level_index - 1][1].instance()
		current_obstacle_wrapper.name = "ObstacleWrapper"
		character_layer.add_child(current_obstacle_wrapper)
		Global.current_level_stop_state = Global.Level_stop_states.TRANSITION_IN
		main_character.reset()

