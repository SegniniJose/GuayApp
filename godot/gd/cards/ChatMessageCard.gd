extends MarginContainer
class_name ChatMessageCard

@onready var left_container: HBoxContainer = %LeftBubbleContainer
@onready var right_container: HBoxContainer = %RightBubbleContainer

@onready var left_avatar: TextureRectUrl = %LeftAvatar
@onready var left_name: Label = %LeftName
@onready var left_message: Label = %LeftMessage
@onready var left_timestamp: Label = %LeftTimestamp

@onready var right_message: Label = %RightMessage
@onready var right_timestamp: Label = %RightTimestamp


func set_chat_message(chat_message: Dictionary):
	var is_me := false
	var sender_avatar := ""
	var content: String = chat_message.get("content", "")
	var ts: String = chat_message.get("timestamp", chat_message.get("CreatedAt", ""))
	var username: String = chat_message.get("username", "")

	if chat_message.has("leagueId"):
		is_me = (str(chat_message.get("userId", "")) == str(Globals.user_id))
		sender_avatar = chat_message.get("avatar", "")
	else:
		is_me = (str(chat_message.get("senderId", "")) == str(Globals.user_id))
		sender_avatar = chat_message.get("senderAvatar", "")

	var time_str: String = Globals.timestamp_to_string(ts) if ts != "" else ""

	if is_me:
		left_container.visible = false
		right_container.visible = true
		right_message.text = content
		right_timestamp.text = time_str
	else:
		right_container.visible = false
		left_container.visible = true
		if left_name and username != "":
			left_name.text = username
		left_message.text = content
		left_timestamp.text = time_str
		if left_avatar:
			await left_avatar.set_url(sender_avatar)
