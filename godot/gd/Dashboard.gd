extends Control
class_name Dashboard

@onready var username_label: Label = %Username
@onready var points_label: Label = %PointsNum
@onready var photos_label: Label = %PhotosNum
@onready var avatar: TextureRectUrl = %Avatar
@onready var profile_card: PanelContainer = %ProfileCard
@onready var private_card: PanelContainer = %PrivateCard
@onready var hero_card: PanelContainer = %HeroCard
@onready var start_btn: Button = %StartBtn

@onready var HttpRequest = %HttpRequest


func _ready() -> void:
	_connect_buttons()
	_connect_private_toggle()
	refresh_username_label()
	refresh_points_label()
	await refresh_avatar()
	refresh_photos_label()
	await load_profile()
	await load_photo_count()
	await load_league_status()
	GuayTheme.fade_in(self)


func _connect_buttons() -> void:
	# Profile card tap -> go to profile
	if profile_card and not profile_card.gui_input.is_connected(_on_profile_card_input):
		profile_card.mouse_filter = Control.MOUSE_FILTER_STOP
		profile_card.gui_input.connect(_on_profile_card_input)


func _connect_private_toggle() -> void:
	var toggle: CheckButton = get_node_or_null("%CheckButton")
	if toggle:
		toggle.button_pressed = Globals.isPrivate
		if not toggle.toggled.is_connected(_on_private_toggled):
			toggle.toggled.connect(_on_private_toggled)


func _on_profile_card_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		Globals.profile_friend_id = Globals.user_id
		get_tree().change_scene_to_file("res://tscn/Profile.tscn")


func _on_private_toggled(button_pressed: bool) -> void:
	Globals.isPrivate = button_pressed


func refresh_photos_label() -> void:
	photos_label.text = str(Globals.photo_count)


func refresh_points_label() -> void:
	points_label.text = str(Globals.points)


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


func load_league_status() -> void:
	if Globals.league_id == "":
		return
	var callback = func(response: Dictionary):
		Globals.league_status = response
	var url = Globals.get_api_leagues_status_url()
	await Globals.http_request_callback(self, url, callback)


func _on_create_league_button_pressed() -> void:
	if Globals.missions.size() > 0:
		Globals.current_mission_id = Globals.missions[0].id
		get_tree().change_scene_to_file("res://tscn/CameraCapture.tscn")
		return
	if Globals.league_status.get("status", "") == "active" or Globals.league_id != "":
		get_tree().change_scene_to_file("res://tscn/Missions.tscn")
		return
	get_tree().change_scene_to_file("res://tscn/Missions.tscn")


func _on_btn_league_pressed() -> void:
	get_tree().change_scene_to_file("res://tscn/Leagues.tscn")


func _on_btn_mission_pressed() -> void:
	get_tree().change_scene_to_file("res://tscn/Missions.tscn")


func _on_btn_validate_pressed() -> void:
	get_tree().change_scene_to_file("res://tscn/MissionValidation.tscn")


func _on_btn_ranking_pressed() -> void:
	get_tree().change_scene_to_file("res://tscn/Ranking.tscn")


func _on_btn_invite_pressed() -> void:
	get_tree().change_scene_to_file("res://tscn/Friends.tscn")
