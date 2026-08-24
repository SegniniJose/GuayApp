extends Node


func _ready() -> void:
	RenderingServer.set_default_clear_color(Color("f4f7fb"))
	_apply()


func _apply() -> void:
	var win := get_window()
	if win == null:
		return

	win.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	win.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_EXPAND
