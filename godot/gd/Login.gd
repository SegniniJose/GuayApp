extends Control
class_name Login

@onready var logo_panel = $Center/Content/Brand/LogoWrap/LogoPanel
@onready var submit_btn = $Center/Content/FormCard/FormVBox/SubmitBtn
@onready var login_section = $Center/Content/FormCard/FormVBox/LoginSection
@onready var login_user_input = $Center/Content/FormCard/FormVBox/LoginSection/User/LineEdit
@onready var login_pass_input = $Center/Content/FormCard/FormVBox/LoginSection/Pass/LineEdit
@onready var register_section = $Center/Content/FormCard/FormVBox/RegisterSection
@onready var register_user_input = $Center/Content/FormCard/FormVBox/RegisterSection/User/LineEdit
@onready var register_email_input = $Center/Content/FormCard/FormVBox/RegisterSection/Email/LineEdit
@onready var register_pass_input = $Center/Content/FormCard/FormVBox/RegisterSection/Pass/LineEdit
@onready var btn_login = $Center/Content/TabSwitcher/TabHBox/BtnLogin
@onready var btn_register = $Center/Content/TabSwitcher/TabHBox/BtnRegister
@onready var card_title = $Center/Content/FormCard/FormVBox/Welcome/Title
@onready var card_subtitle = $Center/Content/FormCard/FormVBox/Welcome/Sub
@onready var form_card = $Center/Content/FormCard
@onready var tab_switcher = $Center/Content/TabSwitcher
@onready var deco_top = $DecoTop
@onready var deco_bottom = $DecoBottom
@onready var login_request = $LoginRequest
@onready var app_title = $Center/Content/Brand/AppTitle
@onready var tagline = $Center/Content/Brand/Tagline
@onready var footer = $Center/Content/Footer

var _field_labels: Array[Label] = []
var _forgot_btn: LinkButton
var _social_row: HBoxContainer
var _create_outline_btn: Button


func _ready() -> void:
	_collect_field_labels()
	_ensure_login_extras()
	_apply_login_styles()
	modulate.a = 0
	var tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "modulate:a", 1.0, 0.5)
	logo_panel.pivot_offset = logo_panel.size / 2
	submit_btn.pivot_offset = submit_btn.size / 2
	login_section.visible = true
	register_section.visible = false
	_animate_logo()
	_animate_deco()


func _ensure_login_extras() -> void:
	# Placeholders and copy from mockup
	login_user_input.placeholder_text = "Correo electrónico o usuario"
	login_pass_input.placeholder_text = "Contraseña"
	card_title.text = "¡Bienvenido a GuayGo!"
	card_subtitle.text = "Inicia sesión para continuar"
	tagline.text = "Conecta. Une. Vive experiencias."
	app_title.text = "[center][font_size=34][color=#0066ff][b]GuayGo[/b][/color][/font_size][/center]"
	footer.text = "💛 Hecho para unir personas  ·  +2.5K personas ya están dentro"

	var chip_m = $Center/Content/Brand/Features/ChipMissions/Label
	var chip_l = $Center/Content/Brand/Features/ChipLeagues/Label
	var chip_r = $Center/Content/Brand/Features/ChipRanking/Label
	chip_m.text = "🎯 Misiones"
	chip_l.text = "🏆 Ligas"
	chip_r.text = "📅 Eventos"

	# Password reveal toggle
	if login_pass_input and login_pass_input.get_parent() is BoxContainer:
		var pass_container = login_pass_input.get_parent()
		if pass_container.get_node_or_null("EyeToggle") == null:
			var eye_btn := Button.new()
			eye_btn.name = "EyeToggle"
			eye_btn.text = "👁"
			eye_btn.flat = true
			eye_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
			eye_btn.pressed.connect(func():
				login_pass_input.secret = not login_pass_input.secret
				eye_btn.modulate = Color.WHITE if login_pass_input.secret else GuayTheme.COLOR_PRIMARY
			)
			pass_container.add_child(eye_btn)

	# Forgot password
	if form_card.get_node_or_null("FormVBox/ForgotRow") == null:
		var forgot_row := HBoxContainer.new()
		forgot_row.name = "ForgotRow"
		forgot_row.alignment = BoxContainer.ALIGNMENT_END
		_forgot_btn = LinkButton.new()
		_forgot_btn.text = "¿Olvidaste tu contraseña?"
		_forgot_btn.underline = LinkButton.UNDERLINE_MODE_NEVER
		_forgot_btn.pressed.connect(_on_forgot_pressed)
		forgot_row.add_child(_forgot_btn)
		form_card.get_node("FormVBox").add_child(forgot_row)
		form_card.get_node("FormVBox").move_child(forgot_row, submit_btn.get_index())

	# Social row (UI del mockup; auth real sigue siendo usuario/clave del backend)
	if form_card.get_node_or_null("FormVBox/SocialBlock") == null:
		var social := VBoxContainer.new()
		social.name = "SocialBlock"
		social.add_theme_constant_override("separation", 10)
		var sep := Label.new()
		sep.text = "—  o continúa con  —"
		sep.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		GuayTheme.apply_label(sep, GuayTheme.FONT_CAPTION, GuayTheme.COLOR_TEXT_MUTED)
		social.add_child(sep)
		_social_row = HBoxContainer.new()
		_social_row.alignment = BoxContainer.ALIGNMENT_CENTER
		_social_row.add_theme_constant_override("separation", 16)
		for pair in [["G", "Google"], ["", "Apple"], ["f", "Facebook"]]:
			var b2 := Button.new()
			b2.custom_minimum_size = Vector2(52, 52)
			b2.text = pair[0]
			b2.tooltip_text = pair[1]
			b2.pressed.connect(_on_social_pressed.bind(pair[1]))
			GuayTheme.apply_button_outline(b2)
			_social_row.add_child(b2)
		social.add_child(_social_row)
		form_card.get_node("FormVBox").add_child(social)

	# Outline "Crear cuenta" under social when on login tab
	if form_card.get_node_or_null("FormVBox/CreateOutline") == null:
		_create_outline_btn = Button.new()
		_create_outline_btn.name = "CreateOutline"
		_create_outline_btn.custom_minimum_size = Vector2(0, 48)
		_create_outline_btn.text = "Crear cuenta"
		_create_outline_btn.pressed.connect(_on_tab_register_pressed)
		form_card.get_node("FormVBox").add_child(_create_outline_btn)


func _collect_field_labels() -> void:
	for section in [login_section, register_section]:
		for child in section.get_children():
			if child is VBoxContainer:
				var label = child.get_node_or_null("Label")
				if label:
					_field_labels.append(label)


func _apply_login_styles() -> void:
	GuayTheme.apply_panel(logo_panel, GuayTheme.logo_box())
	GuayTheme.apply_panel(form_card, GuayTheme.login_card())
	GuayTheme.apply_panel(tab_switcher, GuayTheme.tab_bar_bg())
	GuayTheme.apply_button_primary(submit_btn)
	submit_btn.add_theme_font_size_override("font_size", GuayTheme.FONT_BODY + 1)

	for le in [login_user_input, login_pass_input, register_user_input, register_email_input, register_pass_input]:
		GuayTheme.apply_line_edit(le)

	GuayTheme.apply_label(card_title, GuayTheme.FONT_HEADING, GuayTheme.COLOR_TEXT, true)
	GuayTheme.apply_label(card_subtitle, GuayTheme.FONT_LABEL, GuayTheme.COLOR_TEXT_SECONDARY)
	GuayTheme.apply_label(tagline, GuayTheme.FONT_BODY, GuayTheme.COLOR_PRIMARY, true)
	GuayTheme.apply_label(footer, GuayTheme.FONT_CAPTION, GuayTheme.COLOR_TEXT_MUTED)

	for label in _field_labels:
		GuayTheme.apply_label(label, GuayTheme.FONT_LABEL, GuayTheme.COLOR_TEXT_SECONDARY)

	for chip_path in [
		"Center/Content/Brand/Features/ChipMissions",
		"Center/Content/Brand/Features/ChipLeagues",
		"Center/Content/Brand/Features/ChipRanking",
	]:
		var chip = get_node_or_null(chip_path)
		if chip:
			GuayTheme.apply_panel(chip, GuayTheme.feature_chip())

	if _forgot_btn:
		GuayTheme.apply_link(_forgot_btn)
		_forgot_btn.add_theme_font_size_override("font_size", GuayTheme.FONT_CAPTION)
	if _create_outline_btn:
		GuayTheme.apply_button_outline(_create_outline_btn)

	deco_top.modulate = Color(GuayTheme.COLOR_PRIMARY.r, GuayTheme.COLOR_PRIMARY.g, GuayTheme.COLOR_PRIMARY.b, 0.12)
	deco_bottom.modulate = Color(GuayTheme.COLOR_ACCENT_GOLD.r, GuayTheme.COLOR_ACCENT_GOLD.g, GuayTheme.COLOR_ACCENT_GOLD.b, 0.14)

	_update_tabs(true)


func _animate_logo() -> void:
	var tween = create_tween().set_loops()
	tween.tween_property(logo_panel, "scale", Vector2(1.04, 1.04), 2.2).set_trans(Tween.TRANS_SINE)
	tween.tween_property(logo_panel, "scale", Vector2.ONE, 2.2).set_trans(Tween.TRANS_SINE)


func _animate_deco() -> void:
	var t1 = create_tween().set_loops()
	t1.tween_property(deco_top, "position", deco_top.position + Vector2(0, 12), 5.0).set_trans(Tween.TRANS_SINE)
	t1.tween_property(deco_top, "position", deco_top.position, 5.0).set_trans(Tween.TRANS_SINE)
	var t2 = create_tween().set_loops()
	t2.tween_property(deco_bottom, "position", deco_bottom.position + Vector2(0, -10), 6.0).set_trans(Tween.TRANS_SINE)
	t2.tween_property(deco_bottom, "position", deco_bottom.position, 6.0).set_trans(Tween.TRANS_SINE)


func _on_forgot_pressed() -> void:
	Globals.show_popup(self, "Recuperar acceso", "Escribe a soporte o crea una cuenta nueva con el mismo correo si aún no tienes una.")


func _on_social_pressed(provider: String) -> void:
	Globals.show_popup(
		self,
		provider,
		"El login con %s estará disponible pronto. Por ahora usa usuario/correo y contraseña." % provider
	)


func _on_submit_pressed() -> void:
	if login_section.visible:
		_on_submit_login_pressed()
	if register_section.visible:
		_on_submit_register_pressed()


func _on_submit_login_pressed() -> void:
	var username = login_user_input.text
	var password = login_pass_input.text
	if username.is_empty() or password.is_empty():
		Globals.shake_node(submit_btn)
		Globals.show_error_popup(self, "Completa todos los campos", submit_btn)
		return
	submit_btn.disabled = true
	submit_btn.text = "Conectando..."
	var data = {"identifier": username, "password": password}
	login_request.request("%s/api/auth/login" % Globals.base_url, Globals.headers, HTTPClient.METHOD_POST, JSON.stringify(data))


func _on_submit_register_pressed() -> void:
	var username = register_user_input.text
	var email = register_email_input.text
	var password = register_pass_input.text
	if username.is_empty() or email.is_empty() or password.is_empty():
		Globals.shake_node(submit_btn)
		Globals.show_error_popup(self, "Completa todos los campos", submit_btn)
		return
	submit_btn.disabled = true
	submit_btn.text = "Creando cuenta..."
	var data = {"username": username, "email": email, "password": password}
	login_request.request(Globals.get_api_auth_register_url(), Globals.headers, HTTPClient.METHOD_POST, JSON.stringify(data))


func _on_login_request_completed(_result, response_code, _headers, body) -> void:
	submit_btn.disabled = false
	submit_btn.text = "Entrar a GuayGo  →" if login_section.visible else "Crear mi cuenta  →"
	var callback = func(response: Dictionary):
		Globals.erase_all()
		Globals.set_profile(response)
		get_tree().change_scene_to_file("res://tscn/Dashboard.tscn")
	await Globals.on_request_completed(self, response_code, body, callback)


func _on_tab_login_pressed() -> void:
	_update_tabs(true)
	card_title.text = "¡Bienvenido a GuayGo!"
	card_subtitle.text = "Inicia sesión para continuar"
	submit_btn.text = "Entrar a GuayGo  →"
	login_section.visible = true
	register_section.visible = false
	if _create_outline_btn:
		_create_outline_btn.visible = true
	var social = form_card.get_node_or_null("FormVBox/SocialBlock")
	if social:
		social.visible = true
	var forgot = form_card.get_node_or_null("FormVBox/ForgotRow")
	if forgot:
		forgot.visible = true
	for le in [login_user_input, login_pass_input]:
		GuayTheme.apply_line_edit(le)


func _on_tab_register_pressed() -> void:
	_update_tabs(false)
	card_title.text = "Crea tu cuenta"
	card_subtitle.text = "Únete y empieza tu aventura"
	submit_btn.text = "Crear mi cuenta  →"
	login_section.visible = false
	register_section.visible = true
	if _create_outline_btn:
		_create_outline_btn.visible = false
	var social = form_card.get_node_or_null("FormVBox/SocialBlock")
	if social:
		social.visible = false
	var forgot = form_card.get_node_or_null("FormVBox/ForgotRow")
	if forgot:
		forgot.visible = false
	for le in [register_user_input, register_email_input, register_pass_input]:
		GuayTheme.apply_line_edit(le)


func _update_tabs(is_login: bool) -> void:
	GuayTheme.apply_tab(btn_login, is_login)
	GuayTheme.apply_tab(btn_register, not is_login)
	var tween = create_tween()
	form_card.scale = Vector2(0.97, 0.97)
	tween.tween_property(form_card, "scale", Vector2.ONE, 0.22).set_trans(Tween.TRANS_BACK)
