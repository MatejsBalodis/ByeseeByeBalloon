extends Node

enum Level_stop_states {NONE, LEVEL_COMPLETE, GAME_OVER}
var current_level_stop_state = Level_stop_states.NONE # To inform the whole project about the current level stop state.
var current_level_index = 0 # To know globally, which is the current level.
var current_scene = null # To get the currently loaded scene.
var total_score = 0 # Total amount of points collected between levels.

const APPROXIMATION_FLOAT = .0001 # Global handle.

func _ready():
	var root = get_tree().get_root()
	current_scene = root.get_child(root.get_child_count() -1)
	# goto_scene("res://World.tscn")
	pass

func goto_scene(path):
	call_deferred("_deferred_goto_scene", path)

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

