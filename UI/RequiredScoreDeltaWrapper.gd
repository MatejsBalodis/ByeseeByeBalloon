extends Control

onready var delta_score = get_node("DeltaScore") # For speed and convenience.
onready var delta_score_shadow = get_node("DeltaScoreShadow") # For speed and convenience.
onready var main_character = get_parent().get_parent().get_node("CharacterLayer").get_node("MainCharacter") # For speed and convenience.

var display_score = .0 # To lerp the score that user sees.
var display_level_value = .0 # To lerp to the score required to beat the level.

const MIN_SCORE_REACH_THRESHOLD = 2 # If display score is closer than this to goal score set display to show goal score.
const LERP_SPEED = 3.0 # How quickly to lerp to the new score.

func _process(delta):
	if (weakref(main_character.level)).get_ref():
		display_score = lerp(display_score, Global.total_score, delta * LERP_SPEED)
		display_level_value = lerp(display_level_value, main_character.level.level_value, delta * LERP_SPEED)
		delta_score.text = str(int(display_score if abs(display_score - Global.total_score) > MIN_SCORE_REACH_THRESHOLD else Global.total_score), "/", int(display_level_value if abs(display_level_value - main_character.level.level_value) > MIN_SCORE_REACH_THRESHOLD else main_character.level.level_value))
		delta_score_shadow.text = delta_score.text
