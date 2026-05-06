extends Control

var Resolutions: Dictionary = {"1280x720":Vector2(1280,720),
								"1920x1080":Vector2(1920,1080),
								"2560x1440":Vector2(2560,1440),
								"3840x2160":Vector2(3840,2160)
	
}

# Window Mode Dropdown
func _on_option_button_item_selected(index: int) -> void:
	match index:
		0:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		1:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
