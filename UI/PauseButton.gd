extends Button

onready var game_over_wrapper = get_parent().get_node("GameOverWrapper") # For speed and convenience.
onready var game_over_restart_button = game_over_wrapper.get_node("GameOverRestartButton") # For speed and convenience.
onready var game_over_menu_button = game_over_wrapper.get_node("GameOverMenuButton") # For speed and convenience.
onready var music_audio_stream_player = get_parent().get_parent().get_node("MusicManager").get_child(0) # For speed and convenience.
onready var original_music_volume = music_audio_stream_player.volume_db # To know, where to reset the volume.

const PAUSE_VOLUME_DB = -24.0 # How quite does music become on pause.

func _ready():
	game_over_wrapper = null

func _on_PauseButton_pressed():
	if get_tree().paused:
		get_tree().paused = false
		game_over_restart_button.visible = false
		game_over_menu_button.visible = false
		Global.current_level_stop_state = Global.Level_stop_states.NONE
	else:
		get_tree().paused = true
		game_over_restart_button.visible = true
		game_over_menu_button.visible = true
		Global.current_level_stop_state = Global.Level_stop_states.PAUSE

func _process(delta):
	if get_tree().paused:
		music_audio_stream_player.volume_db = lerp(music_audio_stream_player.volume_db, PAUSE_VOLUME_DB, delta)
	else:
		music_audio_stream_player.volume_db = lerp(music_audio_stream_player.volume_db, original_music_volume, delta)

	if Global.current_level_stop_state == Global.Level_stop_states.LEVEL_COMPLETE || Global.current_level_stop_state == Global.Level_stop_states.GAME_OVER:
		visible = false
	else:
		visible = true
