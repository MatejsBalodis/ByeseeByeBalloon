extends Button

export (Texture) var unpause_button_texture = null # Set texture style to this, when pause is active.

onready var game_over_wrapper = get_parent().get_node("GameOverWrapper") # For speed and convenience.
onready var main_character = game_over_wrapper.get_parent().get_parent().get_node("CharacterLayer").get_node("MainCharacter") # For speed and convenience.
onready var game_over_restart_button = game_over_wrapper.get_node("GameOverRestartButton") # For speed and convenience.
onready var game_over_menu_button = game_over_wrapper.get_node("GameOverMenuButton") # For speed and convenience.
onready var music_audio_stream_player = get_parent().get_parent().get_node("MusicManager").get_child(0) # For speed and convenience.
onready var original_music_volume = music_audio_stream_player.volume_db # To know, where to reset the volume.
onready var original_button_style_texture = self.get("custom_styles/hover").texture # To know, where to reset the texture.

const PAUSE_VOLUME_DB = -24.0 # How quite does music become on pause.

func _ready():
	game_over_wrapper = null

func _on_PauseButton_pressed():
	if get_tree().paused:
		get_tree().paused = false
		game_over_restart_button.visible = false
		game_over_menu_button.visible = false
		Global.current_level_stop_state = Global.Level_stop_states.NONE
		Global.set_custom_button_style_texture(self, original_button_style_texture)
	else:
		get_tree().paused = true
		game_over_restart_button.visible = true
		game_over_menu_button.visible = true
		Global.current_level_stop_state = Global.Level_stop_states.PAUSE
		Global.set_custom_button_style_texture(self, unpause_button_texture)

func _process(delta):
	if get_tree().paused:
		if !game_over_menu_button.visible:
			game_over_menu_button.visible = true
			game_over_restart_button.visible = true
		main_character.fade_in_game_over_elements(delta * main_character.GAME_OVER_ELEMENT_FADE_SPEED)
		music_audio_stream_player.volume_db = lerp(music_audio_stream_player.volume_db, PAUSE_VOLUME_DB, delta)
	else:
		music_audio_stream_player.volume_db = lerp(music_audio_stream_player.volume_db, original_music_volume, delta)

	if Global.current_level_stop_state == Global.Level_stop_states.LEVEL_COMPLETE || Global.current_level_stop_state == Global.Level_stop_states.GAME_OVER:
		if modulate.a < Global.APPROXIMATION_FLOAT:
			visible = false
	elif Global.current_level_stop_state != Global.Level_stop_states.TRANSITION_OUT:
		visible = true
