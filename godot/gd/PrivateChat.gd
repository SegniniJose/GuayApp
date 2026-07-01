extends Control
class_name PrivateChat

@onready var messages = %Messages
@onready var line_edit = %LineEdit

@export var chat_scene: PackedScene = preload("res://tscn/cards/ChatMessageCard.tscn")


func _ready() -> void:
	clear_private_chat()
	await load_private_chat()


func _exit_tree():
	Globals.private_chat_friend_id = ""
	Globals.private_chats = []


func clear_private_chat():
	get_tree().call_group("private_chat", "queue_free")


func refresh_private_chat():
	clear_private_chat()

	for chat_message in Globals.private_chats:
		print("private_chat ", chat_message)
		var new_private_chat = chat_scene.instantiate()
		messages.add_child(new_private_chat)
		new_private_chat.set_chat_message(chat_message)
		new_private_chat.add_to_group("private_chat")


func load_private_chat():
	var callback = func(response: Array):
		print("Private Chat Success!", response)
		Globals.private_chats.clear()
		Globals.private_chats.assign(response)
		refresh_private_chat()
	var url = Globals.get_api_messages_private_url(Globals.user_id, Globals.private_chat_friend_id)
	Globals.http_request_callback(self, url, callback)


func _on_send_btn_pressed() -> void:
	var callback = func(response: Dictionary):
		print("Private Chat Send Success!", response)
		load_private_chat()
	var data = {
		"content": line_edit.text,
		"receiverId": Globals.private_chat_friend_id,
		"senderId": Globals.user_id,
	}
	var url = Globals.get_api_messages_private_post_url()
	await Globals.http_post_callback(self, url, data, callback)
