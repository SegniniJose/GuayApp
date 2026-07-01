extends Control

@onready var messages = %Messages
@onready var line_edit = %LineEdit

@export var chat_scene: PackedScene = preload("res://tscn/cards/ChatMessageCard.tscn")


func _ready() -> void:
	clear_league_chat()
	await load_league_chat()


func _exit_tree():
	Globals.league_chats = []


func clear_league_chat():
	get_tree().call_group("league_chat", "queue_free")


func refresh_league_chat():
	clear_league_chat()

	for chat_message in Globals.league_chats:
		print("league_chat ", chat_message)
		var new_league_chat = chat_scene.instantiate()
		messages.add_child(new_league_chat)
		new_league_chat.set_chat_message(chat_message)
		new_league_chat.add_to_group("league_chat")


func load_league_chat():
	var callback = func(response: Array):
		print("Chat Success!", response)
		Globals.league_chats.clear()
		Globals.league_chats.assign(response)
		refresh_league_chat()
	var url = Globals.get_api_messages_url()
	Globals.http_request_callback(self, url, callback)


func _on_send_btn_pressed() -> void:
	var callback = func(response: Dictionary):
		print("Chat Send Success!", response)
		load_league_chat()
	var data = {
		"content": line_edit.text,
		"leagueId": Globals.league_id,
		"userId": Globals.user_id,
		"type": "text"
	}
	var url = Globals.get_api_messages_post_url()
	await Globals.http_post_callback(self, url, data, callback)
