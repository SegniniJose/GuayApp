extends Control
class_name Profile

@onready var avatar: TextureRectUrl = %Avatar
@onready var username: Label = %Username
@onready var points: Label = %Points
@onready var status: Label = %Status

func _ready() -> void:
	load_profile()

func load_profile():
	var callback = func(response: Dictionary):
		print("Load Profile Success!", response)
		Globals.profile = response
		refresh_profile()
	var url = Globals.get_global_api_users_profile_url()
	await Globals.http_request_callback(self, url, callback)


func refresh_profile():
	print("refresh_profile ", Globals.profile)
	username.text = Globals.profile.username
	points.text = str(Globals.profile.points) + " pts"
	if Globals.profile.get("isPrivate", false):
		status.text = "Perfil privado"
	else:
		status.text = "Perfil público"
	await avatar.set_url(Globals.profile.avatar)


func _on_add_friend_button_pressed() -> void:
	var callback = func(response: Dictionary):
		print("Add Friends Success!", response)
		Globals.profile_friend_id = ""
		get_tree().change_scene_to_file("res://tscn/Friends.tscn")
	var url = Globals.get_api_friends_request_url()
	var data = {
		"userId": Globals.user_id,
		"friendId": Globals.profile_friend_id,
	}
	var request_body = JSON.stringify(data)
	print("_on_add_friend_button_pressed ", url, " ", request_body)
	Globals.http_post_callback(self, url, data, callback)


func _on_message_button_pressed() -> void:
	Globals.private_chat_friend_id = Globals.profile_friend_id
	Globals.profile_friend_id = ""
	get_tree().change_scene_to_file("res://tscn/PrivateChat.tscn")
