extends TextureRect
class_name TextureRectUrl

var url: String = ""


func _ready() -> void:
	pass


# Notice we don't change the function signature, but we add an internal await
func set_url(new_url: String) -> void:
	url = new_url

	if url.is_empty():
		return

	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_on_request_completed)

	var error: Error = http_request.request(url)
	if error != OK:
		push_error("An error occurred while making the HTTP request.")
		return  # Exit early if the request couldn't even start

	await http_request.request_completed
	http_request.queue_free()

	print("Avatar successfully downloaded and applied to texture!")


func _on_request_completed(
	result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray
) -> void:
	if result != HTTPRequest.RESULT_SUCCESS or response_code != 200:
		return

	var image := Image.new()
	var head_bytes: PackedByteArray = body.slice(0, 100)
	var head_str: String = head_bytes.get_string_from_utf8().to_lower()

	if head_str.contains("<svg") or head_str.contains("<?xml"):
		image.load_svg_from_buffer(body, 1.0)
	else:
		image.load_image_from_buffer(body)

	texture = ImageTexture.create_from_image(image)
