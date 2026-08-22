extends Control
class_name Login

## Login alineado al mockup GuayGo: hero + card centrada (PC full / móvil full).

const ROOT := "Scroll/Margin/Content"

@onready var logo_panel = get_node(ROOT + "/Brand/LogoWrap/LogoPanel")
@onready var submit_btn = get_node(ROOT + "/FormCard/FormVBox/SubmitBtn")
@onready var login_section = get_node(ROOT + "/FormCard/FormVBox/LoginSection")
@onready var login_user_input = get_node(ROOT + "/FormCard/FormVBox/LoginSection/User/LineEdit")
@onready var login_pass_input = get_node(ROOT + "/FormCard/FormVBox/LoginSection/Pass/LineEdit")
@onready var register_section = get_node(ROOT + "/FormCard/FormVBox/RegisterSection")
@onready var register_user_input = get_node(ROOT + "/FormCard/FormVBox/RegisterSection/User/LineEdit")
@onready var register_email_input = get_node(ROOT + "/FormCard/FormVBox/RegisterSection/Email/LineEdit")
@onready var register_pass_input = get_node(ROOT + "/FormCard/FormVBox/RegisterSection/Pass/LineEdit")
@onready var btn_login = get_node(ROOT + "/TabSwitcher/TabHBox/BtnLogin")
@onready var btn_register = get_node(ROOT + "/TabSwitcher/TabHBox/BtnRegister")
@onready var card_title = get_node(ROOT + "/FormCard/FormVBox/Welcome/Title")
@onready var card_subtitle = get_node(ROOT + "/FormCard/FormVBox/Welcome/Sub")
@onready var form_card = get_node(ROOT + "/FormCard")
@onready var tab_switcher = get_node(ROOT + "/TabSwitcher")
@onready var deco_top = $DecoTop
@onready var deco_bottom = $DecoBottom
@onready var login_request = $LoginRequest
@onready var app_title = get_node(ROOT + "/Brand/AppTitle")
@onready var tagline = get_node(ROOT + "/Brand/Tagline")
@onready var footer = get_node(ROOT + "/Footer")
@onready var content: VBoxContainer = get_node(ROOT)
@onready var margin: MarginContainer = $Scroll/Margin
@onready var hero: TextureRect = $Hero

var _field_labels: Array[Label] = []
var _forgot_btn: LinkButton
var _social_row: HBoxContainer
var _create_outline_btn: Button
var _desc_label: Label


func _ready() -> void:
	_setup_hero()
	_collect_field_labels()
	_ensure_login_extras()
	_apply_login_styles()
	_adapt_layout()
	get_viewport().size_changed.connect(_adapt_layout)
	modulate.a = 0
	var tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "modulate:a", 1.0, 0.35)
	login_section.visible = true
	register_section.visible = false


func _setup_hero() -> void:
	if hero == null:
		return
	var tex: Texture2D = load("res://assets/login_mockup.jpg")
	if tex:
		hero.texture = tex
		hero.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		hero.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		hero.modulate = Color(1, 1, 1, 0.35)
	# En PC el hero se ve de fondo a pantalla completa; el form queda encima.


func _adapt_layout() -> void:
	var vp := get_viewport_rect().size
	var is_desktop := vp.x >= 900.0
	var side := 16.0
	if is_desktop:
		side = maxf(24.0, (vp.x - 440.0) * 0.5)
	elif vp.x < 400.0:
		side = 12.0
	margin.add_theme_constant_override("margin_left", int(side))
	margin.add_theme_constant_override("margin_right", int(side))
	margin.add_theme_constant_override("margin_top", 20 if is_desktop else 12)
	margin.add_theme_constant_override("margin_bottom", 20 if is_desktop else 12)

	var target_w := 420.0 if is_desktop else clampf(vp.x - side * 2.0, 300.0, 420.0)
	content.custom_minimum_size = Vector2(target_w, 0)
	content.size_flags_horizontal = Control.SIZE_SHRINK_CENTER

	if hero:
		hero.visible = true
		# Más visible el mockup de fondo en desktop
		hero.modulate = Color(1, 1, 1, 0.55 if is_desktop else 0.28)


func _ensure_login_extras() -> void:
	login_user_input.placeholder_text = "Correo electrónico o usuario"
	login_pass_input.placeholder_text = "Contraseña"
	card_title.text = "¡Bienvenido a GuayGo!"
	card_subtitle.text = "Inicia sesión para continuar"
	tagline.text = "Conecta. Une. Vive experiencias."
	app_title.text = "[center][font_size=40][color=#0056e0][b]Guay[/b][/color][color=#ffc107][b]Go[/b][/color][/font_size][/center]"
	footer.text = "💛 Hecho para unir personas   ·   +2.5K personas ya están dentro"

	var brand: VBoxContainer = get_node(ROOT + "/Brand")
	if brand.get_node_or_null("Desc") == null:
		_desc_label = Label.new()
		_desc_label.name = "Desc"
		_desc_label.text = "Completa misiones, participa en ligas, descubre eventos y gana recompensas."
		_desc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		brand.add_child(_desc_label)
		brand.move_child(_desc_label, tagline.get_index() + 1)
	else:
		_desc_label = brand.get_node("Desc")

	var logo_label = logo_panel.get_node_or_null("LogoLabel")
	if logo_label:
		logo_label.text = "G"

	var chip_m = get_node(ROOT + "/Brand/Features/ChipMissions/Label")
	var chip_l = get_node(ROOT + "/Brand/Features/ChipLeagues/Label")
	var chip_r = get_node(ROOT + "/Brand/Features/ChipRanking/Label")
	chip_m.text = "🎯 Misiones"
	chip_l.text = "🏆 Ligas"
	chip_r.text = "📅 Eventos"

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

	if form_card.get_node_or_null("FormVBox/SocialBlock") == null:
		var social := VBoxContainer.new()
		social.name = "SocialBlock"
		social.add_theme_constant_override("separation", 10)
		var sep := Label.new()
		sep.text = "o continúa con"
		sep.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		GuayTheme.apply_label(sep, GuayTheme.FONT_CAPTION, GuayTheme.COLOR_TEXT_MUTED)
		social.add_child(sep)
		_social_row = HBoxContainer.new()
		_social_row.alignment = BoxContainer.ALIGNMENT_CENTER
		_social_row.add_theme_constant_override("separation", 18)
		for pair in [["G", "Google"], ["A", "Apple"], ["f", "Facebook"]]:
			var b2 := Button.new()
			b2.custom_minimum_size = Vector2(52, 52)
			b2.text = pair[0]
			b2.tooltip_text = pair[1]
			b2.pressed.connect(_on_social_pressed.bind(pair[1]))
			GuayTheme.apply_button_outline(b2)
			var circle := GuayTheme.make_flat(Color.WHITE, 26, 4, GuayTheme.COLOR_PRIMARY, 2)
			b2.add_theme_stylebox_override("normal", circle)
			b2.add_theme_stylebox_override("hover", GuayTheme.make_flat(GuayTheme.COLOR_PRIMARY_LIGHT, 26, 4, GuayTheme.COLOR_PRIMARY, 2))
			_social_row.add_child(b2)
		social.add_child(_social_row)
		form_card.get_node("FormVBox").add_child(social)

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
	submit_btn.text = "Entrar a GuayGo  →"
	submit_btn.add_theme_font_size_override("font_size", GuayTheme.FONT_BODY + 1)

	for le in [login_user_input, login_pass_input, register_user_input, register_email_input, register_pass_input]:
		GuayTheme.apply_line_edit(le)

	GuayTheme.apply_label(card_title, GuayTheme.FONT_HEADING, GuayTheme.COLOR_PRIMARY_DARK, true)
	GuayTheme.apply_label(card_subtitle, GuayTheme.FONT_LABEL, GuayTheme.COLOR_TEXT_SECONDARY)
	GuayTheme.apply_label(tagline, GuayTheme.FONT_BODY, GuayTheme.COLOR_PRIMARY, true)
	GuayTheme.apply_label(footer, GuayTheme.FONT_CAPTION, GuayTheme.COLOR_TEXT_MUTED)
	if _desc_label:
		GuayTheme.apply_label(_desc_label, GuayTheme.FONT_CAPTION, GuayTheme.COLOR_TEXT_SECONDARY)

	for label in _field_labels:
		GuayTheme.apply_label(label, GuayTheme.FONT_LABEL, GuayTheme.COLOR_TEXT_SECONDARY)

	for chip_path in [
		ROOT + "/Brand/Features/ChipMissions",
		ROOT + "/Brand/Features/ChipLeagues",
		ROOT + "/Brand/Features/ChipRanking",
	]:
		var chip = get_node_or_null(chip_path)
		if chip:
			GuayTheme.apply_panel(chip, GuayTheme.feature_chip())

	if _forgot_btn:
		GuayTheme.apply_link(_forgot_btn)
	if _create_outline_btn:
		GuayTheme.apply_button_outline(_create_outline_btn)

	deco_top.modulate = Color(GuayTheme.COLOR_PRIMARY.r, GuayTheme.COLOR_PRIMARY.g, GuayTheme.COLOR_PRIMARY.b, 0.18)
	deco_bottom.modulate = Color(GuayTheme.COLOR_ACCENT_GOLD.r, GuayTheme.COLOR_ACCENT_GOLD.g, GuayTheme.COLOR_ACCENT_GOLD.b, 0.16)
	_update_tabs(true)


func _on_forgot_pressed() -> void:
	Globals.show_popup(self, "Recuperar acceso", "Escribe a soporte o crea una cuenta nueva con el mismo correo si aún no tienes una.")


func _on_social_pressed(provider: String) -> void:
	Globals.show_popup(self, "Próximamente", "El login con %s estará disponible pronto. Por ahora usa usuario/correo y contraseña." % provider)


func _on_submit_pressed() -> void:
	if login_section.visible:
		_on_submit_login_pressed()
	else:
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


func _on_tab_register_pressed() -> void:
	_update_tabs(false)
	card_title.text = "Crea tu cuenta"
	card_subtitle.text = "Únete a GuayGo en segundos"
	submit_btn.text = "Crear mi cuenta  →"
	login_section.visible = false
	register_section.visible = true
	if _create_outline_btn:
		_create_outline_btn.visible = false
	var social = form_card.get_node_or_null("FormVBox/SocialBlock")
	if social:
		social.visible = false


func _update_tabs(is_login: bool) -> void:
	GuayTheme.apply_tab(btn_login, is_login)
	GuayTheme.apply_tab(btn_register, not is_login)
