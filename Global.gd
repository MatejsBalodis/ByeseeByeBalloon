extends Node

enum Level_stop_states {NONE, LEVEL_COMPLETE, GAME_OVER, PAUSE, TRANSITION_IN, TRANSITION_OUT, QUIT_GAME, SWITCH_LEVEL_OUT}
var current_level_stop_state = Level_stop_states.NONE # To inform the whole project about the current level stop state.
var current_level_index = 0 # To know globally, which is the current level.
var current_scene = null # To get the currently loaded scene.
var total_score = 0 # Total amount of points collected between levels.
var scene_path = null # Scene to which to switch after transition out.
var level_transition = null # For speed and convenience.

const APPROXIMATION_FLOAT = .0001 # Global handle.

func set_custom_button_style_texture(button, current_texture):
	button.get("custom_styles/hover").texture = current_texture
	button.get("custom_styles/pressed").texture = current_texture
	button.get("custom_styles/disabled").texture = current_texture
	button.get("custom_styles/normal").texture = current_texture

func _ready():
	var root = get_tree().get_root()
	current_scene = root.get_child(root.get_child_count() -1)
	# goto_scene("res://World.tscn")

func transition_to_scene(scene_path):
	self.scene_path = scene_path
	current_level_stop_state = Level_stop_states.TRANSITION_OUT

func transition_and_quit():
	current_level_stop_state = Level_stop_states.QUIT_GAME

func goto_scene():
	call_deferred("_deferred_goto_scene", scene_path)

func _deferred_goto_scene(path):
	current_scene.free()
	# Load new scene.
	var s = ResourceLoader.load(path)
	# Instance the new scene.
	current_scene = s.instance()
	# Add it to the active scene, as child of root.
	get_tree().get_root().add_child(current_scene)
	# Optional, to make it compatible with the SceneTree.change_scene() API.
	get_tree().set_current_scene(current_scene)

