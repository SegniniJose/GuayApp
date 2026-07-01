extends Control
class_name CompleteMission

# --- Node References via Unique Names ---
@onready var cancel_button: Button = %CancelButton
@onready var submit_button: Button = %SubmitButton
@onready var upload_area: PanelContainer = %UploadArea
@onready var file_dialog: FileDialog = %FileDialog

# --- Layout References for Preview Toggling ---
@onready var center_container: CenterContainer = %CenterContainer
@onready var placeholder_content: VBoxContainer = %PlaceholderContent

# --- Properties ---
var selected_image: Image = null
var preview_rect: TextureRect = null


func _ready() -> void:
	cancel_button.pressed.connect(_on_close_pressed)
	submit_button.pressed.connect(_on_submit_pressed)
	upload_area.gui_input.connect(_on_upload_area_input)

	# Configure FileDialog filters for image selection
	file_dialog.filters = PackedStringArray(["*.png ; PNG Images", "*.jpg, *.jpeg ; JPEG Images"])


func _on_close_pressed() -> void:
	get_tree().change_scene_to_file("res://tscn/Missions.tscn")
	hide()


func _on_upload_area_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_trigger_native_file_picker()


func _trigger_native_file_picker() -> void:
	file_dialog.popup_centered_clamped(Vector2i(800, 600))
	if not file_dialog.file_selected.is_connected(_on_file_selected):
		file_dialog.file_selected.connect(_on_file_selected)


func _on_file_selected(path: String) -> void:
	var image = Image.load_from_file(path)
	if image:
		selected_image = image
		_display_image_preview(image)
		Globals.show_popup(self, "Upload Image", "Image Loaded")


func _display_image_preview(img: Image) -> void:
	# Create texture from the loaded image
	var texture := ImageTexture.create_from_image(img)

	# Hide the initial "Tap to take photo" text layout
	placeholder_content.visible = false

	# Clear previous preview if the user picks a different file
	if preview_rect and is_instance_valid(preview_rect):
		preview_rect.queue_free()

	# Instance and configure a TextureRect to scale nicely inside your layout
	preview_rect = TextureRect.new()
	preview_rect.texture = texture
	preview_rect.expand_mode = TextureRect.EXPAND_KEEP_SIZE
	preview_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED

	# Restrict the preview height slightly so it fits inside the 200px UploadArea container
	preview_rect.custom_minimum_size = Vector2(0, 180)

	# Center it inside the upload zone
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
		# Trigger the network upload routine instead of just jumping scenes instantly
		await complete_mission()
	else:
		Globals.show_popup(self, "Upload Image", "Please select an image")
