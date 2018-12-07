extends Area2D

onready var main_character = get_parent().get_parent().get_node("MainCharacter") # For speed and convenience.

func _on_CollisionArea_body_entered(body):
	main_character.set_descrete_facial_animation(2, true)

func _on_CollisionArea_body_exited(body):
	main_character.set_descrete_facial_animation(5, false)
