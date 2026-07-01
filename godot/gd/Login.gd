extends Control
class_name Login

@onready var icon_rect = $BackgroundPanel/MarginContainer/MainVBox/Header/IconRect
@onready var submit_btn = $BackgroundPanel/MarginContainer/MainVBox/Card/Margin/VBox/SubmitBtn

@onready var login_section = $BackgroundPanel/MarginContainer/MainVBox/Card/Margin/VBox/LoginSection
@onready
var login_user_input = $BackgroundPanel/MarginContainer/MainVBox/Card/Margin/VBox/LoginSection/User/LineEdit
@onready
var login_pass_input = $BackgroundPanel/MarginContainer/MainVBox/Card/Margin/VBox/LoginSection/Pass/LineEdit

@onready
var register_section = $BackgroundPanel/MarginContainer/MainVBox/Card/Margin/VBox/RegisterSection
@onready
var register_user_input = $BackgroundPanel/MarginContainer/MainVBox/Card/Margin/VBox/RegisterSection/User/LineEdit
@onready
var register_email_input = $BackgroundPanel/MarginContainer/MainVBox/Card/Margin/VBox/RegisterSection/Email/LineEdit
@onready
var register_pass_input = $BackgroundPanel/MarginContainer/MainVBox/Card/Margin/VBox/RegisterSection/Pass/LineEdit

@onready var btn_login = $BackgroundPanel/MarginContainer/MainVBox/TabContainer/BtnLogin
@onready var btn_register = $BackgroundPanel/MarginContainer/MainVBox/TabContainer/BtnRegister
@onready var card_title = $BackgroundPanel/MarginContainer/MainVBox/Card/Margin/VBox/Welcome/Title
@onready var card_subtitle = $BackgroundPanel/MarginContainer/MainVBox/Card/Margin/VBox/Welcome/Sub

@onready var login_request = $LoginRequest


func _ready():
	# Simple entrance animation
	modulate.a = 0
	var tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "modulate:a", 1.0, 0.5)

	icon_rect.pivot_offset = icon_rect.size / 2
	submit_btn.pivot_offset = submit_btn.size / 2

	login_section.visible = true
	register_section.visible = false

	# Start the idle "hover" rotation for the icon
	_animate_icon_idle()


func _animate_icon_idle():
	var tween = create_tween().set_loops()
	tween.tween_property(icon_rect, "rotation_degrees", 6.0, 2.0).set_trans(Tween.TRANS_SINE)
	tween.tween_property(icon_rect, "rotation_degrees", -6.0, 2.0).set_trans(Tween.TRANS_SINE)


func _on_submit_pressed():
	if login_section.visible:
		_on_submit_login_pressed()
	if register_section.visible:
		_on_submit_register_pressed()


func _on_submit_login_pressed():
	var username = login_user_input.text
	var password = login_pass_input.text

	if username.is_empty() or password.is_empty():
		Globals.shake_node(submit_btn)
		Globals.show_error_popup(self, "Please fill in all fields", submit_btn)
		return

	# Button click "bounce" effect
	var tween = create_tween()
	tween.tween_property(submit_btn, "scale", Vector2(0.95, 0.95), 0.1)
	tween.tween_property(submit_btn, "scale", Vector2(1.0, 1.0), 0.1)

	print("Attempting login for: ", username)
	# Prepare the data
	var data = {"identifier": username, "password": password}

	# Convert data to JSON string
	var json_query = JSON.stringify(data)
	var headers = ["Content-Type: application/json"]

	# Send the POST request
	var url = "%s/api/auth/login" % [Globals.base_url]
	login_request.request(url, headers, HTTPClient.METHOD_POST, json_query)

	# Optional: Disable button while loading
	submit_btn.disabled = true
	submit_btn.text = "Cargando..."


func _on_submit_register_pressed():
	var username = register_user_input.text
	var email = register_email_input.text
	var password = register_pass_input.text

	if username.is_empty() or email.is_empty() or password.is_empty():
		Globals.shake_node(submit_btn)
		Globals.show_error_popup(self, "Please fill in all fields", submit_btn)
		return

	var tween = create_tween()
	tween.tween_property(submit_btn, "scale", Vector2(0.95, 0.95), 0.1)
	tween.tween_property(submit_btn, "scale", Vector2(1.0, 1.0), 0.1)

	print("Attempting login for: ", username)
	var data = {"username": username, "email": email, "password": password}
	var json_query = JSON.stringify(data)

	login_request.request(
		Globals.get_api_auth_register_url(), Globals.headers, HTTPClient.METHOD_POST, json_query
	)

	submit_btn.disabled = true
	submit_btn.text = "Cargando..."


func _on_login_request_completed(_result, response_code, _headers, body):
	submit_btn.disabled = false
	submit_btn.text = "Entrar a GuayGo"

	var callback = func(response: Dictionary):
		print("Login Success!", response)
		Globals.erase_all()
		Globals.set_profile(response)
		get_tree().change_scene_to_file("res://tscn/Dashboard.tscn")

	Globals.on_request_completed(self, response_code, body, callback)


func _on_tab_login_pressed():
	_update_tabs(true)
	card_title.text = "Bienvenido de nuevo"
	card_subtitle.text = "Ingresa tus datos para continuar"
	submit_btn.text = "Entrar a GuayGo"
	login_section.visible = true
	register_section.visible = false


func _on_tab_register_pressed():
	_update_tabs(false)
	card_title.text = "Crea tu cuenta"
	card_subtitle.text = "Únete a la liga y empieza tu aventura"
	submit_btn.text = "Registrarse"
	login_section.visible = false
	register_section.visible = true


func _update_tabs(is_login: bool):
	var active_color = Color.BLACK
	var inactive_color = Color(0.5, 0.5, 0.5)

	btn_login.add_theme_color_override("font_color", active_color if is_login else inactive_color)
	btn_register.add_theme_color_override(
		"font_color", active_color if not is_login else inactive_color
	)

	# Add a small scale "pop" to the card when switching
	var tween = create_tween()
	$BackgroundPanel/MarginContainer/MainVBox/Card.scale = Vector2(0.98, 0.98)
	(
		tween
		. tween_property($BackgroundPanel/MarginContainer/MainVBox/Card, "scale", Vector2.ONE, 0.2)
		. set_trans(Tween.TRANS_BACK)
	)
