extends Node


func _ready() -> void:
	if not _is_mobile():
		return

	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

	var screen_size := DisplayServer.screen_get_size()
	if screen_size.x > 0 and screen_size.y > 0:
		get_window().size = screen_size


func _is_mobile() -> bool:
	return (
		OS.has_feature("mobile")
		or OS.has_feature("Android")
		or OS.has_feature("iOS")
	)
