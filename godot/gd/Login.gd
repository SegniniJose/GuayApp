extends Control
class_name Login

## Login GuayGo: UI en la escena (mockup). Script solo logica + adaptar tamano.

const FORM := "Scroll/Margin/Content/FormCard/FormVBox"

@onready var content: VBoxContainer = %Content
@onready var logo_panel: PanelContainer = %LogoPanel
@onready var app_title: RichTextLabel = %AppTitle
@onready var tagline: Label = %Tagline
@onready var desc: Label = %Desc
@onready var features: HBoxContainer = %Features
@onready var btn_login: Button = %BtnLogin
@onready var btn_register: Button = %BtnRegister
@onready var card_title: Label = %Title
@onready var card_subtitle: Label = %Sub
@onready var login_section: VBoxContainer = %LoginSection
@onready var register_section: VBoxContainer = %RegisterSection
@onready var login_user_input: LineEdit = get_node(FORM + "/LoginSection/User/LineEdit")
@onready var login_pass_input: LineEdit = get_node(FORM + "/LoginSection/Pass/LineEdit")
@onready var register_user_input: LineEdit = get_node(FORM + "/RegisterSection/User/LineEdit")
@onready var register_email_input: LineEdit = get_node(FORM + "/RegisterSection/Email/LineEdit")
@onready var register_pass_input: LineEdit = get_node(FORM + "/RegisterSection/Pass/LineEdit")
@onready var submit_btn: Button = %SubmitBtn
@onready var social_sep: Label = %SocialSep
@onready var social_row: HBoxContainer = %SocialRow
@onready var create_outline: Button = %CreateOutline
@onready var inline_footer: PanelContainer = %InlineFooter
@onready var scroll: ScrollContainer = $Scroll
@onready var login_request: HTTPRequest = $LoginRequest


func _ready() -> void:
	login_section.visible = true
	register_section.visible = false
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	RenderingServer.set_default_clear_color(Color("f7f9fc"))
	_apply_tabs(true)
	_adapt_layout()
	get_viewport().size_changed.connect(_adapt_layout)
	call_deferred("_adapt_layout")


func _adapt_layout() -> void:
	var vp := get_viewport_rect().size
	var h := vp.y
	var w := vp.x
	var card_w := clampf(minf(400.0, w - 32.0), 300.0, 400.0)
	content.custom_minimum_size = Vector2(card_w, 0)

	logo_panel.get_parent().visible = h >= 720.0
	desc.visible = h >= 780.0
	features.visible = h >= 700.0
	tagline.visible = h >= 640.0
	var show_extra := h >= 600.0 and login_section.visible
	social_sep.visible = show_extra
	social_row.visible = show_extra
	create_outline.visible = show_extra
	inline_footer.visible = true

	var title_size := 26 if h < 700.0 else 30
	app_title.text = "[center][font_size=%d][color=#1a56db][b]Guay[/b][/color][color=#ffc107][b]Go[/b][/color][/font_size][/center]" % title_size


func _apply_tabs(is_login: bool) -> void:
	GuayTheme.apply_tab(btn_login, is_login)
	GuayTheme.apply_tab(btn_register, not is_login)


func _on_forgot_pressed() -> void:
	Globals.show_popup(self, "Recuperar acceso", "Escribe a soporte o crea una cuenta nueva con el mismo correo.")


func _on_social_pressed(provider: String = "Social") -> void:
	Globals.show_popup(self, "PrÃ³ximamente", "Login con %s pronto. Usa usuario y contraseÃ±a." % provider)


func _on_submit_pressed() -> void:
	if login_section.visible:
		_do_login()
	else:
		_do_register()


func _do_login() -> void:
	var username := login_user_input.text
	var password := login_pass_input.text
	if username.is_empty() or password.is_empty():
		Globals.shake_node(submit_btn)
		Globals.show_error_popup(self, "Completa todos los campos", submit_btn)
		return
	submit_btn.disabled = true
	submit_btn.text = "Conectando..."
	login_request.request(
		"%s/api/auth/login" % Globals.base_url,
		Globals.headers,
		HTTPClient.METHOD_POST,
		JSON.stringify({"identifier": username, "password": password})
	)


func _do_register() -> void:
	var username := register_user_input.text
	var email := register_email_input.text
	var password := register_pass_input.text
	if username.is_empty() or email.is_empty() or password.is_empty():
		Globals.shake_node(submit_btn)
		Globals.show_error_popup(self, "Completa todos los campos", submit_btn)
		return
	submit_btn.disabled = true
	submit_btn.text = "Creando cuenta..."
	login_request.request(
		Globals.get_api_auth_register_url(),
		Globals.headers,
		HTTPClient.METHOD_POST,
		JSON.stringify({"username": username, "email": email, "password": password})
	)


func _on_login_request_completed(_result, response_code, _headers, body) -> void:
	submit_btn.disabled = false
	submit_btn.text = "Entrar a GuayGo  â†’" if login_section.visible else "Crear mi cuenta"
	var callback = func(response: Dictionary):
		Globals.erase_all()
		Globals.set_profile(response)
		get_tree().change_scene_to_file("res://tscn/Dashboard.tscn")
	await Globals.on_request_completed(self, response_code, body, callback)


func _on_tab_login_pressed() -> void:
	_apply_tabs(true)
	card_title.text = "Â¡Bienvenido a GuayGo!"
	card_subtitle.text = "Inicia sesiÃ³n para continuar"
	submit_btn.text = "Entrar a GuayGo  â†’"
	login_section.visible = true
	register_section.visible = false
	_adapt_layout()


func _on_tab_register_pressed() -> void:
	_apply_tabs(false)
	card_title.text = "Crea tu cuenta"
	card_subtitle.text = "Ãšnete a GuayGo en segundos"
	submit_btn.text = "Crear mi cuenta"
	login_section.visible = false
	register_section.visible = true
	social_sep.visible = false
	social_row.visible = false
	create_outline.visible = false

