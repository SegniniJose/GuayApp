extends Control
class_name Profile

@onready var avatar: TextureRectUrl = %Avatar
@onready var username: Label = %Username
@onready var points: Label = %Points
@onready var photos: Label = %Photos
@onready var status: Label = %Status
@onready var action_buttons: HBoxContainer = %ActionButtons


func _ready() -> void:
	load_profile()
	GuayTheme.fade_in(self)


func load_profile():
	var callback = func(response: Dictionary):
		Globals.profile = response
		refresh_profile()
	var url = Globals.get_global_api_users_profile_url()
	await Globals.http_request_callback(self, url, callback)


func refresh_profile():
	var is_me = (Globals.profile_friend_id == "" or Globals.profile_friend_id == Globals.user_id)
	if action_buttons:
		action_buttons.visible = not is_me

	username.text = str(Globals.profile.get("username", Globals.username if Globals.username != "" else "Jugador"))
	points.text = str(Globals.profile.get("points", Globals.points))
	photos.text = str(Globals.profile.get("photoCount", Globals.photo_count))

	if Globals.profile.get("isPrivate", false):
		status.text = "Perfil privado"
	else:
		status.text = "Perfil público"

	await avatar.set_url(Globals.profile.get("avatar", Globals.avatar))


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
