extends Button

export (Texture) var windowed_texture = null # Use this texture for windowd button.

onready var fullscreen_texture = get("custom_styles/hover").texture # For speed and convenience.

func _on_FullscreenButton_pressed():
	if !OS.window_fullscreen:
		OS.window_fullscreen = true
		Global.set_custom_button_style_texture(self, windowed_texture)
	else:
		OS.window_fullscreen = false
		Global.set_custom_button_style_texture(self, fullscreen_texture)
