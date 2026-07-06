extends Control
class_name CompleteMission

@onready var cancel_button: Button = %CancelButton
@onready var submit_button: Button = %SubmitButton
@onready var upload_area: PanelContainer = %UploadArea
@onready var file_dialog: FileDialog = %FileDialog
@onready var center_container: CenterContainer = %CenterContainer
@onready var placeholder_content: VBoxContainer = %PlaceholderContent

var selected_image: Image = null
var preview_rect: TextureRect = null


func _ready() -> void:
	cancel_button.pressed.connect(_on_close_pressed)
	submit_button.pressed.connect(_on_submit_pressed)
	upload_area.gui_input.connect(_on_upload_area_input)

	file_dialog.filters = PackedStringArray(["*.png ; PNG Images", "*.jpg, *.jpeg ; JPEG Images"])
	file_dialog.use_native_dialog = true

	if Globals.temp_captured_image:
		_apply_selected_image(Globals.temp_captured_image)
		Globals.temp_captured_image = null
	elif Globals.open_gallery_on_complete_mission:
		Globals.open_gallery_on_complete_mission = false
		await get_tree().process_frame
		_open_gallery_picker()


func _on_close_pressed() -> void:
	get_tree().change_scene_to_file("res://tscn/Missions.tscn")
	hide()


func _on_upload_area_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_show_photo_source_menu()


func _show_photo_source_menu() -> void:
	if OS.has_feature("mobile") or OS.has_feature("Android") or OS.has_feature("iOS"):
		_open_camera_capture()
	else:
		_open_gallery_picker()


func _open_camera_capture() -> void:
	get_tree().change_scene_to_file("res://tscn/CameraCapture.tscn")


func _open_gallery_picker() -> void:
	file_dialog.popup_centered_ratio(0.9)
	if not file_dialog.file_selected.is_connected(_on_file_selected):
		file_dialog.file_selected.connect(_on_file_selected)


func _on_file_selected(path: String) -> void:
	var image := Image.load_from_file(path)
	if image:
		_apply_selected_image(image)
	else:
		Globals.show_error_popup(self, "No se pudo cargar la imagen seleccionada.", null)


func _apply_selected_image(img: Image) -> void:
	selected_image = img
	_display_image_preview(img)


func _display_image_preview(img: Image) -> void:
	var texture := ImageTexture.create_from_image(img)
	placeholder_content.visible = false

	if preview_rect and is_instance_valid(preview_rect):
		preview_rect.queue_free()

	preview_rect = TextureRect.new()
	preview_rect.texture = texture
	preview_rect.expand_mode = TextureRect.EXPAND_KEEP_SIZE
	preview_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	preview_rect.custom_minimum_size = Vector2(0, 180)
	center_container.add_child(preview_rect)


func complete_mission() -> void:
	if Globals.league_id == "":
		return
	if Globals.current_mission_id == "":
		return

	var callback = func(response: Dictionary):
		print("League Mission Complete Success!", response)
		Globals.current_mission_id = ""
		get_tree().change_scene_to_file("res://tscn/Missions.tscn")

	var url = Globals.get_api_missions_complete_post_url()
	var data = {
		"leagueId": Globals.league_id,
		"photoUrl": SvgTranscoder.image_to_svg_base64(selected_image),
		"userId": Globals.user_id,
	}
	await Globals.http_post_callback(self, url, data, callback)


func _on_submit_pressed() -> void:
	if selected_image != null:
		await complete_mission()
	else:
		Globals.show_error_popup(self, "Selecciona o toma una foto antes de subir.", null)
