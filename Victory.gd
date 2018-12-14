extends Node2D

onready var display_score = 0 # Display this score.
onready var score_background = get_node("UICanvasLayer").get_node("ScoreBackground") # For speed and background.

const SCORE_LERP_SPEED = 5.0 # How quickly to lerp the score up.

func _process(delta):
	display_score = lerp(display_score, Global.total_score, delta * SCORE_LERP_SPEED)
	var int_display_score = str(Global.total_score if display_score > Global.total_score - 2 else int(display_score))
	score_background.get_node("Score").text = int_display_score
	score_background.get_node("Shadow").text = int_display_score
