extends Control
class_name Dashboard

@onready var username_label: Label = %Username
@onready var points_label: RichTextLabel = %Points
@onready var photos_label: RichTextLabel = %Photos
@onready var avatar: TextureRectUrl = %Avatar

@onready var HttpRequest = %HttpRequest

@onready var league_container: VBoxContainer = %LeagueVBoxContainer

func _ready() -> void:
	print("Dashboard _ready started")
	refresh_username_label()
	refresh_points_label()
	await refresh_avatar()
	refresh_photos_label()
	await load_profile()
	await load_photo_count()
	await load_league_status()
	print("Dashboard _ready success")


func refresh_photos_label() -> void:
	photos_label.text = (
		"[center][b][font_size=30][color=gray]%s[/color][/font_size][/b]\n[font_size=18][color=gray]fotos[/color][/font_size][/center]"
		% Globals.photo_count
	)


func refresh_points_label() -> void:
	points_label.text = (
		"[center][b][font_size=30][color=gray]%s[/color][/font_size][/b]\n[font_size=18][color=gray]pts[/color][/font_size][/center]"
		% Globals.points
	)


func refresh_avatar() -> void:
	await avatar.set_url(Globals.avatar)


func refresh_username_label() -> void:
	username_label.text = Globals.username


func load_profile() -> void:
	var callback = func(response: Dictionary):
		print("Profile Success!", response)
		Globals.set_profile(response)
		refresh_username_label()
		refresh_points_label()
		await refresh_avatar()
	var url = Globals.get_api_users_profile_url(Globals.user_id, Globals.user_id)
	HttpRequest.request(url, Globals.headers, HTTPClient.METHOD_GET)
	var http_response = await HttpRequest.request_completed
	var response_code = http_response[1]
	var body = http_response[3]
	Globals.on_request_completed(self, response_code, body, callback)


func load_photo_count() -> void:
	var callback = func(response: Dictionary):
		print("Photo Count Success!", response)
		Globals.photo_count = response.count
		refresh_photos_label()
	var url = Globals.get_api_users_photo_count_url(Globals.user_id)
	HttpRequest.request(url, Globals.headers, HTTPClient.METHOD_GET)
	var http_response = await HttpRequest.request_completed
	var response_code = http_response[1]
	var body = http_response[3]
	Globals.on_request_completed(self, response_code, body, callback)


func refresh_league_status() -> void:
	if Globals.league_status.status == "active":
		league_container.visible = false


func load_league_status() -> void:
	print("load_league_status '", Globals.league_id, "'")
	if Globals.league_id == "":
		return
	var callback = func(response: Dictionary):
		print("League Status Success!", response)
		Globals.league_status = response
		refresh_league_status()
	var url = Globals.get_api_leagues_status_url()
	await Globals.http_request_callback(self, url, callback)


func _on_create_league_button_pressed() -> void:
	get_tree().change_scene_to_file("res://tscn/Leagues.tscn")
