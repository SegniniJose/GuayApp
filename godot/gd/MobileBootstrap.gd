extends Node

## Optimización por dispositivo: móvil, tablet y escritorio/web.
enum DeviceClass { PHONE, TABLET, DESKTOP }

var _last_class: DeviceClass = DeviceClass.PHONE


func _ready() -> void:
	get_tree().root.size_changed.connect(_on_size_changed)
	call_deferred("_apply_for_device")


func _on_size_changed() -> void:
	_apply_for_device()


func _apply_for_device() -> void:
	var kind := detect_device_class()
	_last_class = kind

	# Web: el HTML/CSS controla el marco del canvas; solo ajustamos scale.
	if OS.has_feature("web"):
		_apply_web(kind)
		return

	match kind:
		DeviceClass.PHONE:
			_apply_phone_native()
		DeviceClass.TABLET:
			_apply_tablet_native()
		DeviceClass.DESKTOP:
			_apply_desktop_native()


func detect_device_class() -> DeviceClass:
	if OS.has_feature("Android") or OS.has_feature("iOS") or OS.has_feature("mobile"):
		var screen := DisplayServer.screen_get_size()
		var short_side := mini(screen.x, screen.y)
		# Tablets suelen superar ~600–700 px en el lado corto (densidad lógica).
		if short_side >= 700:
			return DeviceClass.TABLET
		return DeviceClass.PHONE

	if OS.has_feature("web"):
		var vp := get_viewport().get_visible_rect().size
		if vp.x < 600:
			return DeviceClass.PHONE
		if vp.x < 1024:
			return DeviceClass.TABLET
		return DeviceClass.DESKTOP

	# Windows / macOS / Linux editor o export desktop
	return DeviceClass.DESKTOP


func _apply_web(_kind: DeviceClass) -> void:
	var win := get_window()
	if win:
		win.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
		win.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_EXPAND


func _apply_phone_native() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	var screen := DisplayServer.screen_get_size()
	if screen.x > 0 and screen.y > 0:
		get_window().size = screen
	var win := get_window()
	win.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	win.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_EXPAND
	win.content_scale_factor = 1.0


func _apply_tablet_native() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	var screen := DisplayServer.screen_get_size()
	if screen.x > 0 and screen.y > 0:
		get_window().size = screen
	var win := get_window()
	win.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	win.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_EXPAND
	# Un poco más de aire en tablets para no estirar tipografía.
	win.content_scale_factor = 1.0


func _apply_desktop_native() -> void:
	var win := get_window()
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	# Ventana tipo teléfono centrada y usable en PC.
	var target := Vector2i(430, 860)
	win.size = target
	win.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	win.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_KEEP
	win.content_scale_factor = 1.0
	var screen := DisplayServer.screen_get_size()
	if screen.x > target.x and screen.y > target.y:
		win.position = Vector2i((screen.x - target.x) / 2, (screen.y - target.y) / 2)
