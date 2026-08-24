extends Control
class_name Profile

@onready var avatar: TextureRectUrl = %Avatar
@onready var username: Label = %Username
@onready var points: Label = %Points
@onready var status: Label = %Status

func _ready() -> void:
	_apply_profile_styles()
	load_profile()
	GuayTheme.fade_in(self)


func _apply_profile_styles() -> void:
	var stats_card = get_node_or_null("BackgroundPanel/MarginContainer/VBox/StatsCard")
	if stats_card:
		GuayTheme.apply_panel(stats_card, GuayTheme.panel_surface())
	var add_btn = get_node_or_null("BackgroundPanel/MarginContainer/VBox/Buttons/AddFriendButton")
	if add_btn:
		GuayTheme.apply_button_primary(add_btn)
	var msg_btn = get_node_or_null("BackgroundPanel/MarginContainer/VBox/Buttons/MessageButton")
	if msg_btn:
		GuayTheme.apply_button_outline(msg_btn)


func load_profile():
	var callback = func(response: Dictionary):
		Globals.profile = response
		refresh_profile()
	var url = Globals.get_global_api_users_profile_url()
	await Globals.http_request_callback(self, url, callback)


func refresh_profile():
	username.text = Globals.profile.get("username", "Jugador")
	GuayTheme.apply_label(username, GuayTheme.FONT_HEADING, GuayTheme.COLOR_TEXT, true)
	points.text = "%s pts" % str(Globals.profile.get("points", 0))
	GuayTheme.apply_label(points, GuayTheme.FONT_BODY, GuayTheme.COLOR_PRIMARY, true)

	if Globals.profile.get("isPrivate", false):
		status.text = "🔒 Perfil privado"
	else:
		status.text = "🌐 Perfil público"
	GuayTheme.apply_label(status, GuayTheme.FONT_LABEL, GuayTheme.COLOR_TEXT_SECONDARY)

	await avatar.set_url(Globals.profile.get("avatar", ""))


func _on_add_friend_button_pressed() -> void:
	var callback = func(_response: Dictionary):
		Globals.profile_friend_id = ""
		get_tree().change_scene_to_file("res://tscn/Friends.tscn")
	var url = Globals.get_api_friends_request_url()
	var data = {
		"userId": Globals.user_id,
		"friendId": Globals.profile_friend_id,
	}
	Globals.http_post_callback(self, url, data, callback)


func _on_message_button_pressed() -> void:
	Globals.private_chat_friend_id = Globals.profile_friend_id
	Globals.profile_friend_id = ""
	get_tree().change_scene_to_file("res://tscn/PrivateChat.tscn")
