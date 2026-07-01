extends PanelContainer
class_name InviteFriendBubbleCard

@onready var avatar: TextureRectUrl = %Avatar
@onready var friend_name: RichTextLabel = %FriendName

var friend_id: String = ""


func set_users_suggestion(users_suggestion: Dictionary):
	print("set_users_suggestion ", users_suggestion)
	friend_id = users_suggestion.id
	friend_name.text = users_suggestion.username
	await avatar.set_url(users_suggestion.avatar)

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		var callback = func(response: Dictionary):
			print("Add Friends Success!", response)
			get_tree().change_scene_to_file("res://tscn/Dashboard.tscn")
		var url = Globals.get_api_friends_request_url()
		var data = {
			"userId": Globals.user_id,
			"friendId": friend_id,
		}
		Globals.http_post_callback(self, url, data, callback)
