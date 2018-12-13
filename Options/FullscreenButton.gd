extends Button

export (Texture) var windowed_texture = null # Use this texture for windowd button.

onready var fullscreen_texture = get("custom_styles/hover").texture # For speed and convenience.

func set_custom_button_style(current_texture):
	get("custom_styles/hover").texture = current_texture
	get("custom_styles/pressed").texture = current_texture
	get("custom_styles/disabled").texture = current_texture
	get("custom_styles/normal").texture = current_texture

func _on_FullscreenButton_pressed():
	if !OS.window_fullscreen:
		OS.window_fullscreen = true
		set_custom_button_style(windowed_texture)
	else:
		OS.window_fullscreen = false
		set_custom_button_style(fullscreen_texture)
