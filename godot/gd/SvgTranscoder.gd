extends Node
class_name SvgTranscoder


static func image_to_svg_base64(img: Image) -> String:
	if img == null or img.is_empty():
		push_error("Cannot convert an empty or null image.")
		return ""
	var png_bytes: PackedByteArray = img.save_png_to_buffer()
	var base64_png: String = Marshalls.raw_to_base64(png_bytes)
	var png_data_uri: String = "data:image/png;base64," + base64_png
	var width: int = img.get_width()
	var height: int = img.get_height()
	var svg_template: String = (
		'<svg xmlns="http://www.w3.org/2000/svg" '
		+ 'width="{w}" height="{h}" viewBox="0 0 {w} {h}">'
		+ '<image width="{w}" height="{h}" href="{uri}"/>'
		+ "</svg>"
	)
	var svg_xml: String = svg_template.format({"w": width, "h": height, "uri": png_data_uri})
	var svg_bytes: PackedByteArray = svg_xml.to_utf8_buffer()
	var base64_svg: String = Marshalls.raw_to_base64(svg_bytes)
	return "data:image/svg+xml;base64," + base64_svg


static func get_png_data_uri(svg_base64_uri: String) -> String:
	var svg_prefix = "data:image/svg+xml;base64,"
	if not svg_base64_uri.begins_with(svg_prefix):
		push_error("Invalid SVG Data URI prefix.")
		return ""
	var base64_svg: String = svg_base64_uri.trim_prefix(svg_prefix)

	var svg_bytes: PackedByteArray = Marshalls.base64_to_raw(base64_svg)
	var parser := XMLParser.new()
	var err = parser.open_buffer(svg_bytes)
	if err != OK:
		push_error("Failed to parse SVG XML structure.")
		return ""
	while parser.read() == OK:
		if parser.get_node_type() == XMLParser.NODE_ELEMENT:
			if parser.get_node_name() == "image":
				for i in range(parser.get_attribute_count()):
					if parser.get_attribute_name(i) == "href":
						var attr_idx: int = i
						return parser.get_attribute_value(attr_idx)
	return ""


static func svg_base64_to_image(svg_base64_uri: String) -> Image:
	if svg_base64_uri.is_empty():
		push_error("SVG Base64 string is empty.")
		return null

	var png_data_uri: String = ""
	var png_prefix = "data:image/png;base64,"
	if svg_base64_uri.begins_with(png_prefix):
		png_data_uri = svg_base64_uri
	else:
		png_data_uri = get_png_data_uri(svg_base64_uri)

	if png_data_uri.is_empty():
		push_error("Could not find embedded PNG data URI inside the SVG.")
		return null

	# 4. Strip the inner PNG Data URI prefix
	if not png_data_uri.begins_with(png_prefix):
		push_error("Embedded image is not a valid PNG Base64 URI.")
		return null
	var base64_png: String = png_data_uri.trim_prefix(png_prefix)

	# 5. Decode the PNG Base64 into bytes and load it into a Godot Image
	var png_bytes: PackedByteArray = Marshalls.base64_to_raw(base64_png)
	var img := Image.new()
	var load_err = img.load_png_from_buffer(png_bytes)

	if load_err != OK:
		push_error("Failed to reconstruct Image from PNG buffer.")
		return null

	return img
