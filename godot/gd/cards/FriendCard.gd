extends PanelContainer
class_name FriendCard

@onready var avatar: TextureRectUrl = %Avatar
@onready var friend_name: Label = %FriendName
@onready var status_line: Label = %StatusLine
@onready var chat_btn: Button = %Chat

var friend_id: String = ""


func set_friend(friend: Dictionary):
	friend_id = str(friend.get("id", ""))
	var uname = friend.get("username", "Amigo")
	var pts = friend.get("points", 0)
	var short_id = friend_id.substr(0, 6).to_upper() if friend_id.length() >= 6 else friend_id

	friend_name.text = uname
	status_line.text = "ID: %s  •  %s pts" % [short_id, str(pts)]
	await avatar.set_url(friend.get("avatar", ""))


func _on_chat_pressed() -> void:
	Globals.private_chat_friend_id = friend_id
	get_tree().change_scene_to_file("res://tscn/PrivateChat.tscn")


func _on_avatar_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		Globals.profile_friend_id = friend_id
		get_tree().change_scene_to_file("res://tscn/Profile.tscn")
