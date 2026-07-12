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
	GuayTheme.apply_panel(welcome_panel, GuayTheme.panel_welcome())
	GuayTheme.apply_label(username_label, GuayTheme.FONT_HEADING, GuayTheme.COLOR_TEXT, true)
	GuayTheme.apply_button_primary(create_btn)
	create_btn.add_theme_font_size_override("font_size", GuayTheme.FONT_BODY)
	create_btn.text = "Buscar o crear liga →"
	avatar.custom_minimum_size = Vector2(72, 72)


func refresh_photos_label() -> void:
	photos_label.text = GuayTheme.stat_bbcode(Globals.photo_count, "fotos", "#8b5cf6")


func refresh_points_label() -> void:
	points_label.text = GuayTheme.stat_bbcode(Globals.points, "puntos", "#f59e0b")


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
	get_tree().change_scene_to_file("res://tscn/Leagues.tscn")
