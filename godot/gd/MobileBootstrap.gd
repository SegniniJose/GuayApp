extends Node

## Pantalla completa en web, móvil y escritorio (sin marcos).
enum DeviceClass { PHONE, TABLET, DESKTOP }


func _ready() -> void:
	get_tree().root.size_changed.connect(_apply_for_device)
	call_deferred("_apply_for_device")


func _apply_for_device() -> void:
	var win := get_window()
	win.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	win.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_EXPAND
	win.content_scale_factor = 1.0

	if OS.has_feature("web"):
		# El canvas HTML ya es 100vw/100vh; no forzar tamaños raros.
		return

	if OS.has_feature("Android") or OS.has_feature("iOS") or OS.has_feature("mobile"):
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		var screen := DisplayServer.screen_get_size()
		if screen.x > 0 and screen.y > 0:
			win.size = screen
		return

	# Desktop nativo: ventana usable a pantalla casi completa
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)
