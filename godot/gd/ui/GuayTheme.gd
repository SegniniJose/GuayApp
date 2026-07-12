extends RefCounted
class_name GuayTheme

# Paleta profesional GuayGo
const COLOR_PRIMARY := Color("6366f1")
const COLOR_PRIMARY_DARK := Color("4f46e5")
const COLOR_PRIMARY_LIGHT := Color("eef2ff")
const COLOR_BG := Color("f1f5f9")
const COLOR_SURFACE := Color("ffffff")
const COLOR_TEXT := Color("0f172a")
const COLOR_TEXT_SECONDARY := Color("475569")
const COLOR_TEXT_MUTED := Color("64748b")
const COLOR_BORDER := Color("e2e8f0")
const COLOR_ACCENT_GOLD := Color("f59e0b")
const COLOR_ACCENT_VIOLET := Color("8b5cf6")
const COLOR_SUCCESS := Color("10b981")
const COLOR_DANGER := Color("ef4444")
const COLOR_HEADER_BG := Color("ffffff")

const FONT_TITLE := 28
const FONT_HEADING := 22
const FONT_BODY := 16
const FONT_LABEL := 14
const FONT_CAPTION := 12
const FONT_STAT := 32


static func make_flat(
	bg: Color,
	radius: int = 16,
	shadow: int = 0,
	border: Color = Color.TRANSPARENT,
	border_w: int = 0
) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = bg
	s.set_corner_radius_all(radius)
	s.border_color = border
	s.set_border_width_all(border_w)
	if shadow > 0:
		s.shadow_color = Color(0, 0, 0, 0.08)
		s.shadow_size = shadow
		s.shadow_offset = Vector2(0, 4)
	return s


static func panel_surface() -> StyleBoxFlat:
	return make_flat(COLOR_SURFACE, 20, 12, COLOR_BORDER, 1)


static func panel_primary() -> StyleBoxFlat:
	return make_flat(COLOR_PRIMARY, 16, 8)


static func panel_primary_hover() -> StyleBoxFlat:
	return make_flat(COLOR_PRIMARY_DARK, 16, 10)


static func panel_stat_gold() -> StyleBoxFlat:
	var s := make_flat(Color("fffbeb"), 14, 6, Color("fde68a"), 1)
	return s


static func panel_stat_violet() -> StyleBoxFlat:
	var s := make_flat(Color("f5f3ff"), 14, 6, Color("ddd6fe"), 1)
	return s


static func panel_welcome() -> StyleBoxFlat:
	var s := make_flat(COLOR_PRIMARY_LIGHT, 18, 8, COLOR_PRIMARY, 2)
	return s


static func panel_nav() -> StyleBoxFlat:
	var s := make_flat(COLOR_SURFACE, 0, 16)
	s.corner_radius_top_left = 24
	s.corner_radius_top_right = 24
	s.border_color = COLOR_BORDER
	s.border_width_top = 1
	return s


static func input_normal() -> StyleBoxFlat:
	return make_flat(COLOR_SURFACE, 12, 0, COLOR_BORDER, 1)


static func input_focus() -> StyleBoxFlat:
	return make_flat(COLOR_SURFACE, 12, 0, COLOR_PRIMARY, 2)


static func header_bar() -> StyleBoxFlat:
	return make_flat(COLOR_HEADER_BG, 0, 8)


static func stat_bbcode(value: int, label: String, accent_hex: String) -> String:
	return (
		"[center][font_size=%d][color=%s][b]%s[/b][/color][/font_size]\n"
		+ "[font_size=%d][color=#475569]%s[/color][/font_size][/center]"
	) % [FONT_STAT, accent_hex, str(value), FONT_CAPTION + 2, label]


static func apply_label(node: Label, size: int = FONT_BODY, color: Color = COLOR_TEXT, bold: bool = false) -> void:
	node.add_theme_font_size_override("font_size", size)
	node.add_theme_color_override("font_color", color)
	if bold:
		node.add_theme_constant_override("outline_size", 0)


static func apply_button_primary(btn: Button) -> void:
	btn.add_theme_font_size_override("font_size", FONT_BODY)
	btn.add_theme_color_override("font_color", Color.WHITE)
	btn.add_theme_stylebox_override("normal", panel_primary())
	btn.add_theme_stylebox_override("hover", panel_primary_hover())
	btn.add_theme_stylebox_override("pressed", panel_primary_hover())
	btn.add_theme_stylebox_override("focus", panel_primary())


static func apply_button_ghost(btn: Button, color: Color = COLOR_TEXT_SECONDARY) -> void:
	btn.flat = true
	btn.add_theme_font_size_override("font_size", FONT_LABEL)
	btn.add_theme_color_override("font_color", color)
	btn.add_theme_color_override("font_hover_color", COLOR_PRIMARY)
	btn.add_theme_color_override("font_pressed_color", COLOR_PRIMARY_DARK)


static func apply_link(btn: LinkButton, color: Color = COLOR_PRIMARY) -> void:
	btn.add_theme_font_size_override("font_size", FONT_BODY)
	btn.add_theme_color_override("font_color", color)
	btn.add_theme_color_override("font_hover_color", COLOR_PRIMARY_DARK)


static func apply_line_edit(le: LineEdit) -> void:
	le.add_theme_font_size_override("font_size", FONT_BODY)
	le.add_theme_color_override("font_color", COLOR_TEXT)
	le.add_theme_color_override("font_placeholder_color", COLOR_TEXT_MUTED)
	le.add_theme_stylebox_override("normal", input_normal())
	le.add_theme_stylebox_override("focus", input_focus())


static func apply_panel(container: PanelContainer, style: StyleBoxFlat) -> void:
	container.add_theme_stylebox_override("panel", style)


static func fade_in(node: CanvasItem, duration: float = 0.35) -> void:
	if node == null:
		return
	node.modulate.a = 0.0
	var tween := node.create_tween()
	tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "modulate:a", 1.0, duration)
