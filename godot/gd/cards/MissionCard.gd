extends PanelContainer

var id = ""
var _icon_label: Label
var _desc_label: Label
var _pts_label: Label
var _arrow_label: Label


func _ready() -> void:
	GuayTheme.apply_panel(self, GuayTheme.panel_surface())
	custom_minimum_size = Vector2(0, 72)
	mouse_filter = Control.MOUSE_FILTER_STOP
	_build_ui()


func _build_ui() -> void:
	if get_node_or_null("MainMargin") != null:
		return
	
	# Hide old label if exists
	var old_lbl = get_node_or_null("Label")
	if old_lbl:
		old_lbl.visible = false

	var margin := MarginContainer.new()
	margin.name = "MainMargin"
	margin.add_theme_constant_override("margin_left", 14)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_right", 14)
	margin.add_theme_constant_override("margin_bottom", 12)

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 14)
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER

	# Icon container
	var icon_panel := PanelContainer.new()
	icon_panel.custom_minimum_size = Vector2(44, 44)
	var icon_style := StyleBoxFlat.new()
	icon_style.bg_color = Color("f0fdf4") # soft green / pastel
	icon_style.set_corner_radius_all(12)
	icon_panel.add_theme_stylebox_override("panel", icon_style)

	_icon_label = Label.new()
	_icon_label.text = "🌱"
	_icon_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_icon_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	GuayTheme.apply_label(_icon_label, GuayTheme.FONT_HEADING)
	icon_panel.add_child(_icon_label)

	# Text column
	var text_vbox := VBoxContainer.new()
	text_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_vbox.add_theme_constant_override("separation", 2)

	_desc_label = Label.new()
	_desc_label.text = "Misión"
	GuayTheme.apply_label(_desc_label, GuayTheme.FONT_LABEL + 1, GuayTheme.COLOR_TEXT, true)

	_pts_label = Label.new()
	_pts_label.text = "10.0 pts"
	GuayTheme.apply_label(_pts_label, GuayTheme.FONT_LABEL, GuayTheme.COLOR_PRIMARY, true)

	text_vbox.add_child(_desc_label)
	text_vbox.add_child(_pts_label)

	# Chevron arrow
	_arrow_label = Label.new()
	_arrow_label.text = "›"
	GuayTheme.apply_label(_arrow_label, GuayTheme.FONT_TITLE, GuayTheme.COLOR_TEXT_MUTED)

	hbox.add_child(icon_panel)
	hbox.add_child(text_vbox)
	hbox.add_child(_arrow_label)
	margin.add_child(hbox)
	add_child(margin)


func set_mission(mission: Dictionary):
	_build_ui()
	id = str(mission.get("id", ""))
	var desc: String = mission.get("description", mission.get("title", "Misión"))
	_desc_label.text = desc

	var pts_val = mission.get("points", 10)
	var pts_str = "%.1f pts" % float(pts_val)
	if mission.get("completed", false):
		pts_str += "  ·  ✓ Completada"
		_pts_label.add_theme_color_override("font_color", GuayTheme.COLOR_SUCCESS)
	elif mission.get("isPending", false):
		pts_str += "  ·  ⏳ En validación"
		_pts_label.add_theme_color_override("font_color", GuayTheme.COLOR_ACCENT_GOLD)
	else:
		_pts_label.add_theme_color_override("font_color", GuayTheme.COLOR_PRIMARY)
	_pts_label.text = pts_str

	# Determine appropriate emoji
	var lower = desc.to_lower()
	if "verde" in lower or "planta" in lower or "arbol" in lower:
		_icon_label.text = "🌱"
	elif "perro" in lower or "gato" in lower or "mascota" in lower:
		_icon_label.text = "🐶"
	elif "café" in lower or "cafe" in lower or "taza" in lower:
		_icon_label.text = "☕"
	elif "amigo" in lower or "amiga" in lower or "persona" in lower:
		_icon_label.text = "👥"
	elif "amanecer" in lower or "atardecer" in lower or "cielo" in lower or "sol" in lower:
		_icon_label.text = "🌅"
	elif "libro" in lower or "leer" in lower:
		_icon_label.text = "📖"
	else:
		_icon_label.text = "📸"


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			if typeof(Globals.missions) == TYPE_ARRAY:
				for m in Globals.missions:
					if str(m.get("id", "")) == str(id) and m.get("completed", false):
						Globals.show_popup(self, "Misión", "Ya completaste esta misión.")
						return
			Globals.current_mission_id = id
			get_tree().change_scene_to_file("res://tscn/CameraCapture.tscn")
