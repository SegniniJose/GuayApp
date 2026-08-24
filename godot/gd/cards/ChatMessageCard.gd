extends VSplitContainer
class_name ChatMessageCard

@onready var left_container: HBoxContainer = %LeftBubbleContainer
@onready var right_container: HBoxContainer = %RightBubbleContainer

@onready var left_avatar: TextureRectUrl = %LeftAvatar
@onready var right_avatar: TextureRectUrl = %RightAvatar

@onready var left_message: RichTextLabel = %LeftMessage
@onready var right_message: RichTextLabel = %RightMessage

@onready var left_timestamp: RichTextLabel = %LeftTimestamp
@onready var right_timestamp: RichTextLabel = %RightTimestamp


func set_chat_message(chat_message: Dictionary):
	var is_me = false
	var sender_avatar = ""
	var content = chat_message.get("content", "")
	var ts = chat_message.get("timestamp", chat_message.get("CreatedAt", ""))
	var username = chat_message.get("username", "")

	if chat_message.has("leagueId"):
		is_me = (str(chat_message.get("userId", "")) == str(Globals.user_id))
		sender_avatar = chat_message.get("avatar", "")
	else:
		is_me = (str(chat_message.get("senderId", "")) == str(Globals.user_id))
		sender_avatar = chat_message.get("senderAvatar", "")

	var time_str = Globals.timestamp_to_string(ts) if ts != "" else ""

	if is_me:
		left_container.visible = false
		right_container.visible = true
		right_message.text = content
		right_timestamp.text = time_str
		if right_avatar:
			await right_avatar.set_url(Globals.avatar)
	else:
		right_container.visible = false
		left_container.visible = true
		if username != "":
			left_message.text = "[b]%s[/b]\n%s" % [username, content]
		else:
			left_message.text = content
		left_timestamp.text = time_str
		if left_avatar:
			await left_avatar.set_url(sender_avatar)
