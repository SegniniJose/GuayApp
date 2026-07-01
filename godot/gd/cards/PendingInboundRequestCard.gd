extends PanelContainer
class_name PendingInboundRequestCard

@onready var avatar: TextureRectUrl = %Avatar
@onready var friend_name: RichTextLabel = %FriendName
@onready var status: RichTextLabel = %Status

var friendshipId: String = ""
var friendId: String = ""


func set_pending_inbound_request(pending_inbound_request: Dictionary):
	print("set_pending_inbound_request ", pending_inbound_request)
	var user = pending_inbound_request.user
	friend_name.text = user.username
	friendshipId = pending_inbound_request.id
	friendId = user.id
	await avatar.set_url(user.avatar)


func _on_accept_button_pressed() -> void:
	var callback = func(response: Dictionary):
		print("_on_accept_button_pressed", response)
		get_tree().change_scene_to_file("res://tscn/Friends.tscn")
	var data = {
		"friendId": friendId,
		"friendshipId": friendshipId,
		"userId": Globals.user_id,
	}
	var url = Globals.get_api_friends_accept_url()
	await Globals.http_post_callback(self, url, data, callback)


func _on_decline_button_pressed() -> void:
	var callback = func(response: Dictionary):
		print("_on_decline_button_pressed", response)
		get_tree().change_scene_to_file("res://tscn/Friends.tscn")
	var data = {
		"friendshipId": friendshipId,
	}
	var url = Globals.get_api_friends_reject_url()
	await Globals.http_post_callback(self, url, data, callback)
