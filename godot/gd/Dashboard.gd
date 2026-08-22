extends Control
class_name Dashboard

@onready var username_label: Label = %Username
@onready var points_label: RichTextLabel = %Points
@onready var photos_label: RichTextLabel = %Photos
@onready var avatar: TextureRectUrl = %Avatar
@onready var profile_card: PanelContainer = %ProfileCard
@onready var private_card: PanelContainer = %PrivateToggleCard
@onready var welcome_panel: PanelContainer = %WelcomePanel
@onready var create_btn: Button = %CreateLeagueButton

@onready var HttpRequest = %HttpRequest
@onready var league_container: VBoxContainer = %LeagueVBoxContainer


func _ready() -> void:
	_apply_dashboard_styles()
	refresh_username_label()
	refresh_points_label()
	await refresh_avatar()
	refresh_photos_label()
	await load_profile()
	await load_photo_count()
	await load_league_status()
	GuayTheme.fade_in(self)


func _apply_dashboard_styles() -> void:
	GuayTheme.apply_panel(profile_card, GuayTheme.panel_surface())
	GuayTheme.apply_panel(private_card, GuayTheme.panel_surface())
	GuayTheme.apply_panel(welcome_panel, GuayTheme.panel_hero())
	GuayTheme.apply_label(username_label, GuayTheme.FONT_HEADING, GuayTheme.COLOR_PRIMARY, true)
	# Botón amarillo como mockup "Empezar misión"
	var gold_btn := GuayTheme.make_flat(GuayTheme.COLOR_ACCENT_GOLD, 18, 8)
	create_btn.add_theme_stylebox_override("normal", gold_btn)
	create_btn.add_theme_stylebox_override("hover", GuayTheme.make_flat(Color("ffb300"), 18, 8))
	create_btn.add_theme_color_override("font_color", GuayTheme.COLOR_TEXT)
	create_btn.add_theme_font_size_override("font_size", GuayTheme.FONT_BODY)
	create_btn.text = "Empezar misión  →"
	avatar.custom_minimum_size = Vector2(72, 72)

	# Hero: MISIÓN RECOMENDADA (mockup Inicio)
	var welcome_title = welcome_panel.get_node_or_null("Margin/TextContent/Title")
	var welcome_desc = welcome_panel.get_node_or_null("Margin/TextContent/Desc")
	if welcome_title:
		welcome_title.text = "¡Completa tu primera misión y gana puntos!"
		GuayTheme.apply_label(welcome_title, GuayTheme.FONT_HEADING, Color.WHITE, true)
	if welcome_desc:
		welcome_desc.text = "📷  Haz una foto de una taza de café   ·   +10 pts"
		GuayTheme.apply_label(welcome_desc, GuayTheme.FONT_LABEL, Color(1, 1, 1, 0.92))

	var private_title = private_card.get_node_or_null("HBox/TextContent/Title")
	var private_sub = private_card.get_node_or_null("HBox/TextContent/Subtitle")
	if private_title:
		private_title.text = "Perfil privado"
		GuayTheme.apply_label(private_title, GuayTheme.FONT_BODY, GuayTheme.COLOR_TEXT, true)
	if private_sub:
		private_sub.text = "Solo tus amigos pueden ver tu galería"
		GuayTheme.apply_label(private_sub, GuayTheme.FONT_CAPTION, GuayTheme.COLOR_TEXT_MUTED)

	var how = league_container.get_node_or_null("HowItWorksPanel")
	if how:
		GuayTheme.apply_panel(how, GuayTheme.panel_surface())
		var how_header = how.get_node_or_null("Margin/Rows/Header")
		if how_header:
			how_header.text = "Únete a una liga\nCompleta misiones con fotos\nLa comunidad valida (2 votos)\nSube en el ranking"
			GuayTheme.apply_label(how_header, GuayTheme.FONT_LABEL, GuayTheme.COLOR_TEXT_SECONDARY)


func refresh_photos_label() -> void:
	photos_label.text = GuayTheme.stat_bbcode(Globals.photo_count, "fotos", "#ffc107")


func refresh_points_label() -> void:
	points_label.text = GuayTheme.stat_bbcode(Globals.points, "puntos", "#0066ff")


func refresh_avatar() -> void:
	await avatar.set_url(Globals.avatar)


func refresh_username_label() -> void:
	username_label.text = Globals.username if Globals.username != "" else "Jugador"


func load_profile() -> void:
	var callback = func(response: Dictionary):
		Globals.set_profile(response)
		refresh_username_label()
		refresh_points_label()
		await refresh_avatar()
	var url = Globals.get_api_users_profile_url(Globals.user_id, Globals.user_id)
	HttpRequest.request(url, Globals.headers, HTTPClient.METHOD_GET)
	var http_response = await HttpRequest.request_completed
	Globals.on_request_completed(self, http_response[1], http_response[3], callback)


func load_photo_count() -> void:
	var callback = func(response: Dictionary):
		Globals.photo_count = response.count
		refresh_photos_label()
	var url = Globals.get_api_users_photo_count_url(Globals.user_id)
	HttpRequest.request(url, Globals.headers, HTTPClient.METHOD_GET)
	var http_response = await HttpRequest.request_completed
	Globals.on_request_completed(self, http_response[1], http_response[3], callback)


func refresh_league_status() -> void:
	if Globals.league_status.get("status", "") == "active":
		league_container.visible = false


func load_league_status() -> void:
	if Globals.league_id == "":
		return
	var callback = func(response: Dictionary):
		Globals.league_status = response
		refresh_league_status()
	var url = Globals.get_api_leagues_status_url()
	await Globals.http_request_callback(self, url, callback)


func _on_create_league_button_pressed() -> void:
	if Globals.league_status.get("status", "") == "active" or Globals.league_id != "":
		get_tree().change_scene_to_file("res://tscn/Missions.tscn")
		return
	get_tree().change_scene_to_file("res://tscn/Leagues.tscn")
