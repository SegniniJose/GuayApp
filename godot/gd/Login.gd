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

var _field_labels: Array[Label] = []


func _ready() -> void:
	_collect_field_labels()
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

	for label in _field_labels:
		GuayTheme.apply_label(label, GuayTheme.FONT_LABEL, GuayTheme.COLOR_TEXT_SECONDARY)

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
	card_title.text = "Bienvenido de nuevo"
	card_subtitle.text = "Ingresa tus datos para continuar"
	submit_btn.text = "Entrar a GuayGo  →"
	login_section.visible = true
	register_section.visible = false


func _on_tab_register_pressed() -> void:
	_update_tabs(false)
	card_title.text = "Crea tu cuenta"
	card_subtitle.text = "Únete a la liga y empieza tu aventura"
	submit_btn.text = "Crear mi cuenta  →"
	login_section.visible = false
	register_section.visible = true


func _update_tabs(is_login: bool) -> void:
	GuayTheme.apply_tab(btn_login, is_login)
	GuayTheme.apply_tab(btn_register, not is_login)
	var tween = create_tween()
	form_card.scale = Vector2(0.97, 0.97)
	tween.tween_property(form_card, "scale", Vector2.ONE, 0.22).set_trans(Tween.TRANS_BACK)
