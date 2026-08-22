extends Node

## Escala nítida + pantalla completa (sin barras negras ni blur).


func _ready() -> void:
	RenderingServer.set_default_clear_color(Color("f7f9fc"))
	get_tree().root.size_changed.connect(_apply)
	call_deferred("_apply")


func _apply() -> void:
	var win := get_window()
	if win == null:
		return

	# Clave: desactivar content-scale. El canvas web ya es 1:1 con el píxel.
	# Así no hay letterbox negro ni upscale borroso desde 390px.
	win.content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	win.content_scale_factor = 1.0

	if OS.has_feature("web"):
		return

	if OS.has_feature("Android") or OS.has_feature("iOS") or OS.has_feature("mobile"):
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		var screen := DisplayServer.screen_get_size()
		if screen.x > 0 and screen.y > 0:
			win.size = screen
		return

	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)
