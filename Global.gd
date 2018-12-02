extends Node

var game_over_is_active = false # For the whole project to know, when game over is active.
const APPROXIMATION_FLOAT = .0001 # Global handle.

var current_scene = null

func _ready():
	# var root = get_tree().get_root()
	# current_scene = root.get_child(root.get_child_count() -1)
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
