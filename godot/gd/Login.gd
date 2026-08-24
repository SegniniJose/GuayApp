extends Control
class_name Login

@onready var submit_btn: Button = %SubmitBtn
@onready var login_section: VBoxContainer = %LoginSection
@onready var register_section: VBoxContainer = %RegisterSection
@onready var card_title: Label = %Title
@onready var card_subtitle: Label = %Sub
@onready var toggle_account_btn: Button = %ToggleAccountBtn
@onready var login_request: HTTPRequest = $LoginRequest

@onready var login_user_input: LineEdit = %LoginSection/User/LineEdit
@onready var login_pass_input: LineEdit = %LoginSection/Pass/LineEdit
@onready var register_user_input: LineEdit = %RegisterSection/RegUser/LineEdit
@onready var register_email_input: LineEdit = %RegisterSection/RegEmail/LineEdit
@onready var register_pass_input: LineEdit = %RegisterSection/RegPass/LineEdit

var _is_login_mode: bool = true


func _ready() -> void:
	login_section.visible = true
	register_section.visible = false
	GuayTheme.fade_in(self)


func _on_toggle_account_pressed() -> void:
	_is_login_mode = not _is_login_mode
	if _is_login_mode:
		card_title.text = "¡Bienvenido a GuayGo!"
		card_subtitle.text = "Inicia sesión para continuar"
		submit_btn.text = "Entrar a GuayGo  >"
		toggle_account_btn.text = "Crear cuenta"
		login_section.visible = true
		register_section.visible = false
	else:
		card_title.text = "Crea tu cuenta"
		card_subtitle.text = "Únete y empieza tu aventura"
		submit_btn.text = "Crear mi cuenta  >"
		toggle_account_btn.text = "Ya tengo cuenta (Iniciar sesión)"
		login_section.visible = false
		register_section.visible = true


func _on_forgot_pressed() -> void:
	Globals.show_popup(self, "Recuperar contraseña", "Para restablecer tu contraseña, introduce tu correo o contacta a soporte.")


func _on_social_pressed(provider: String) -> void:
	if provider == "Google":
		if OS.has_feature("web"):
			_login_with_google_firebase()
		else:
			Globals.show_popup(self, provider, "En móvil/escritorio, usa tu correo o usuario para acceder.")
	else:
		Globals.show_popup(
			self,
			provider,
			"El inicio de sesión con %s estará disponible próximamente." % provider
		)


func _login_with_google_firebase() -> void:
	submit_btn.disabled = true
	submit_btn.text = "Conectando con Google..."
	JavaScriptBridge.eval("window._guayGoogleIdToken = null; window._guayGoogleError = null; window.signInWithGoogle && window.signInWithGoogle();")

	for i in range(50):
		await get_tree().create_timer(0.4).timeout
		var err_val = JavaScriptBridge.eval("window._guayGoogleError")
		if err_val != null and str(err_val) != "" and str(err_val) != "<null>":
			submit_btn.disabled = false
			submit_btn.text = "Entrar a GuayGo  >" if _is_login_mode else "Crear mi cuenta  >"
			Globals.show_error_popup(self, "Error al iniciar sesión con Google: " + str(err_val), submit_btn)
			return

		var token_val = JavaScriptBridge.eval("window._guayGoogleIdToken")
		if token_val != null and str(token_val) != "" and str(token_val) != "<null>":
			var id_token: String = str(token_val)
			var data := {"idToken": id_token}
			login_request.request(
				"%s/api/auth/firebase" % Globals.base_url,
				Globals.headers,
				HTTPClient.METHOD_POST,
				JSON.stringify(data)
			)
			return

	submit_btn.disabled = false
	submit_btn.text = "Entrar a GuayGo  >" if _is_login_mode else "Crear mi cuenta  >"


func _on_submit_pressed() -> void:
	if _is_login_mode:
		_on_submit_login_pressed()
	else:
		_on_submit_register_pressed()


func _on_submit_login_pressed() -> void:
	var username: String = login_user_input.text.strip_edges()
	var password: String = login_pass_input.text
	if username.is_empty() or password.is_empty():
		Globals.shake_node(submit_btn)
		Globals.show_error_popup(self, "Por favor completa todos los campos", submit_btn)
		return
	submit_btn.disabled = true
	submit_btn.text = "Conectando..."
	var data := {"identifier": username, "password": password}
	login_request.request(
		"%s/api/auth/login" % Globals.base_url,
		Globals.headers,
		HTTPClient.METHOD_POST,
		JSON.stringify(data)
	)


func _on_submit_register_pressed() -> void:
	var username: String = register_user_input.text.strip_edges()
	var email: String = register_email_input.text.strip_edges()
	var password: String = register_pass_input.text
	if username.is_empty() or email.is_empty() or password.is_empty():
		Globals.shake_node(submit_btn)
		Globals.show_error_popup(self, "Por favor completa todos los campos", submit_btn)
		return
	submit_btn.disabled = true
	submit_btn.text = "Creando cuenta..."
	var data := {"username": username, "email": email, "password": password}
	login_request.request(
		Globals.get_api_auth_register_url(),
		Globals.headers,
		HTTPClient.METHOD_POST,
		JSON.stringify(data)
	)


func _on_login_request_completed(_result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	submit_btn.disabled = false
	submit_btn.text = "Entrar a GuayGo  >" if _is_login_mode else "Crear mi cuenta  >"
	var callback := func(response: Dictionary):
		Globals.erase_all()
		Globals.set_profile(response)
		get_tree().change_scene_to_file("res://tscn/Dashboard.tscn")
	await Globals.on_request_completed(self, response_code, body, callback)
