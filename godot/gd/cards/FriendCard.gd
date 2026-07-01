extends PanelContainer
class_name FriendCard

@onready var avatar: TextureRectUrl = %Avatar
@onready var friend_name: RichTextLabel = %FriendName
@onready var points: RichTextLabel = %Points

var friend_id: String = ""


func set_friend(friend: Dictionary):
	print("set_friend ", friend)
	friend_id = friend.id
	friend_name.text = friend.username
	points.text = str(friend.points) + " pts"
	await avatar.set_url(friend.avatar)


func _on_chat_pressed() -> void:
	Globals.private_chat_friend_id = friend_id
	get_tree().change_scene_to_file("res://tscn/PrivateChat.tscn")


func _on_avatar_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		Globals.profile_friend_id = friend_id
		get_tree().change_scene_to_file("res://tscn/Profile.tscn")
