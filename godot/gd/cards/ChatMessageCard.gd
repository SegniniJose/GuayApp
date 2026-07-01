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
	print("set_chat_message ", chat_message)
	if chat_message.has("leagueId"):
		if chat_message.userId == Globals.user_id:
			right_container.visible = false
			await left_avatar.set_url(chat_message.avatar)
			left_message.text = chat_message.content
			left_timestamp.text = Globals.timestamp_to_string(chat_message.timestamp)
		else:
			left_container.visible = false
			await right_avatar.set_url(chat_message.avatar)
			right_message.text = chat_message.content
			right_timestamp.text = Globals.timestamp_to_string(chat_message.timestamp)
	else:
		if chat_message.senderId == Globals.user_id:
			right_container.visible = false
			await left_avatar.set_url(chat_message.senderAvatar)
			left_message.text = chat_message.content
			left_timestamp.text = Globals.timestamp_to_string(chat_message.timestamp)
		else:
			left_container.visible = false
			await right_avatar.set_url(chat_message.senderAvatar)
			right_message.text = chat_message.content
			right_timestamp.text = Globals.timestamp_to_string(chat_message.timestamp)
