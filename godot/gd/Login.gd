extends Control
class_name Login

@onready var icon_rect = $BackgroundPanel/MarginContainer/MainVBox/Header/IconRect
@onready var submit_btn = $BackgroundPanel/MarginContainer/MainVBox/Card/Margin/VBox/SubmitBtn
@onready var login_section = $BackgroundPanel/MarginContainer/MainVBox/Card/Margin/VBox/LoginSection
@onready var login_user_input = $BackgroundPanel/MarginContainer/MainVBox/Card/Margin/VBox/LoginSection/User/LineEdit
@onready var login_pass_input = $BackgroundPanel/MarginContainer/MainVBox/Card/Margin/VBox/LoginSection/Pass/LineEdit
@onready var register_section = $BackgroundPanel/MarginContainer/MainVBox/Card/Margin/VBox/RegisterSection
@onready var register_user_input = $BackgroundPanel/MarginContainer/MainVBox/Card/Margin/VBox/RegisterSection/User/LineEdit
@onready var register_email_input = $BackgroundPanel/MarginContainer/MainVBox/Card/Margin/VBox/RegisterSection/Email/LineEdit
@onready var register_pass_input = $BackgroundPanel/MarginContainer/MainVBox/Card/Margin/VBox/RegisterSection/Pass/LineEdit
@onready var btn_login = $BackgroundPanel/MarginContainer/MainVBox/TabContainer/BtnLogin
@onready var btn_register = $BackgroundPanel/MarginContainer/MainVBox/TabContainer/BtnRegister
@onready var card_title = $BackgroundPanel/MarginContainer/MainVBox/Card/Margin/VBox/Welcome/Title
@onready var card_subtitle = $BackgroundPanel/MarginContainer/MainVBox/Card/Margin/VBox/Welcome/Sub
@onready var card_panel = $BackgroundPanel/MarginContainer/MainVBox/Card
@onready var bg_panel = $BackgroundPanel
@onready var login_request = $LoginRequest


func _ready() -> void:
	_apply_login_styles()
	modulate.a = 0
	var tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "modulate:a", 1.0, 0.45)
	icon_rect.pivot_offset = icon_rect.size / 2
	submit_btn.pivot_offset = submit_btn.size / 2
	login_section.visible = true
	register_section.visible = false
	_animate_icon_idle()


func _apply_login_styles() -> void:
	GuayTheme.apply_panel(bg_panel, GuayTheme.make_flat(GuayTheme.COLOR_BG, 0))
	GuayTheme.apply_panel(card_panel, GuayTheme.panel_surface())
	GuayTheme.apply_button_primary(submit_btn)
	GuayTheme.apply_line_edit(login_user_input)
	GuayTheme.apply_line_edit(login_pass_input)
	GuayTheme.apply_line_edit(register_user_input)
	GuayTheme.apply_line_edit(register_email_input)
	GuayTheme.apply_line_edit(register_pass_input)
	GuayTheme.apply_label(card_title, GuayTheme.FONT_HEADING, GuayTheme.COLOR_TEXT, true)
	GuayTheme.apply_label(card_subtitle, GuayTheme.FONT_LABEL, GuayTheme.COLOR_TEXT_SECONDARY)
	_update_tabs(true)


func _animate_icon_idle() -> void:
	var tween = create_tween().set_loops()
	tween.tween_property(icon_rect, "rotation_degrees", 4.0, 2.0).set_trans(Tween.TRANS_SINE)
	tween.tween_property(icon_rect, "rotation_degrees", -4.0, 2.0).set_trans(Tween.TRANS_SINE)


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
	submit_btn.text = "Cargando..."
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
	submit_btn.text = "Cargando..."
	var data = {"username": username, "email": email, "password": password}
	login_request.request(Globals.get_api_auth_register_url(), Globals.headers, HTTPClient.METHOD_POST, JSON.stringify(data))


func _on_login_request_completed(_result, response_code, _headers, body) -> void:
	submit_btn.disabled = false
	submit_btn.text = "Entrar a GuayGo" if login_section.visible else "Registrarse"
	var callback = func(response: Dictionary):
		Globals.erase_all()
		Globals.set_profile(response)
		get_tree().change_scene_to_file("res://tscn/Dashboard.tscn")
	await Globals.on_request_completed(self, response_code, body, callback)


func _on_tab_login_pressed() -> void:
	_update_tabs(true)
	card_title.text = "Bienvenido de nuevo"
	card_subtitle.text = "Ingresa tus datos para continuar"
	submit_btn.text = "Entrar a GuayGo"
	login_section.visible = true
	register_section.visible = false


func _on_tab_register_pressed() -> void:
	_update_tabs(false)
	card_title.text = "Crea tu cuenta"
	card_subtitle.text = "Únete a la liga y empieza tu aventura"
	submit_btn.text = "Registrarse"
	login_section.visible = false
	register_section.visible = true


func _update_tabs(is_login: bool) -> void:
	btn_login.add_theme_color_override("font_color", GuayTheme.COLOR_TEXT if is_login else GuayTheme.COLOR_TEXT_MUTED)
	btn_register.add_theme_color_override("font_color", GuayTheme.COLOR_TEXT if not is_login else GuayTheme.COLOR_TEXT_MUTED)
	btn_login.add_theme_font_size_override("font_size", GuayTheme.FONT_BODY)
	btn_register.add_theme_font_size_override("font_size", GuayTheme.FONT_BODY)
	var tween = create_tween()
	card_panel.scale = Vector2(0.98, 0.98)
	tween.tween_property(card_panel, "scale", Vector2.ONE, 0.2).set_trans(Tween.TRANS_BACK)
