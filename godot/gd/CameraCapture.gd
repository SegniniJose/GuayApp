extends Control
class_name CameraCapture

@onready var preview: TextureRect = %Preview
@onready var status_label: Label = %StatusLabel

var _camera_texture: CameraTexture = null
var _feed_id: int = -1


func _ready() -> void:
	_request_camera_permission()
	await get_tree().process_frame
	_start_camera()


func _request_camera_permission() -> void:
	var os_name := OS.get_name()
	if os_name == "Android":
		OS.request_permissions(
			PackedStringArray(
				[
					"android.permission.CAMERA",
					"android.permission.READ_MEDIA_IMAGES",
				]
			)
		)
	elif os_name == "iOS":
		OS.request_permissions(PackedStringArray(["camera"]))


func _start_camera() -> void:
	CameraServer.set_monitoring(true)
	await get_tree().create_timer(0.35).timeout

	if CameraServer.get_feed_count() == 0:
		_show_status("No se pudo abrir la cámara. Usa la galería.")
		return

	var feed := CameraServer.get_feed(0)
	_feed_id = feed.get_id()
	feed.set_active(true)

	_camera_texture = CameraTexture.new()
	_camera_texture.camera_feed_id = _feed_id
	preview.texture = _camera_texture
	_show_status("Encuadra la foto y pulsa Capturar")


func _show_status(message: String) -> void:
	status_label.text = message


func _capture_image() -> Image:
	if _camera_texture == null:
		return null

	var image := _camera_texture.get_image()
	if image == null or image.is_empty():
		return null

	return image


func _stop_camera() -> void:
	if _feed_id >= 0:
		var feed := CameraServer.get_feed(_feed_id)
		if feed:
			feed.set_active(false)
	_camera_texture = null
	CameraServer.set_monitoring(false)


func _return_with_image(image: Image) -> void:
	Globals.temp_captured_image = image
	_stop_camera()
	get_tree().change_scene_to_file("res://tscn/CompleteMission.tscn")


func _on_capture_pressed() -> void:
	var image := _capture_image()
	if image == null:
		Globals.show_error_popup(self, "No se pudo capturar la foto. Intenta de nuevo.", null)
		return
	_return_with_image(image)


func _on_gallery_pressed() -> void:
	_stop_camera()
	get_tree().change_scene_to_file("res://tscn/CompleteMission.tscn")
	Globals.open_gallery_on_complete_mission = true


func _on_cancel_pressed() -> void:
	_stop_camera()
	get_tree().change_scene_to_file("res://tscn/Missions.tscn")
