extends Button

func _on_FullscreenButton_pressed():
	if !OS.window_fullscreen:
		OS.window_fullscreen = true
		text = "Windowed"
	else:
		OS.window_fullscreen = false
		text = "Fullscreen"
