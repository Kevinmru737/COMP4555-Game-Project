extends Control

@onready var resolution_option: OptionButton = $ResolutionOption

# Window Mode Dropdown
func _on_option_button_item_selected(index: int) -> void:
	match index:
		0: DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		1: DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

# Resolution Dropdown
func _on_resolution_option_item_selected(index: int) -> void:
	match index:
		0: DisplayServer.window_set_size(Vector2i(1280, 720))
		1: DisplayServer.window_set_size(Vector2i(1920, 1080))
		2: DisplayServer.window_set_size(Vector2i(2560, 1440))
		3: DisplayServer.window_set_size(Vector2i(3840, 2160))
		
# VSync Toggle
func _on_v_sync_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
