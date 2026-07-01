extends Node
class_name Header

@onready var friend_suggestion_count: RichTextLabel = %FriendSuggestionCount
@onready var notifications_count: RichTextLabel = %NotificationsCount
@onready var HttpRequest = %HttpRequest

@export var invite_friend_bubble_card_scene: PackedScene = preload("res://tscn/cards/InviteFriendBubbleCard.tscn")

func _ready() -> void:
	#await Globals.show_popup(self, "_ready", "_ready")
	await load_suggestions()
	await load_summary()


func _on_exit_button_pressed() -> void:
	Globals.erase_all()
	get_tree().change_scene_to_file("res://tscn/Login.tscn")


func _on_back_btn_pressed() -> void:
	get_tree().change_scene_to_file("res://tscn/Dashboard.tscn")


func _on_notifications_pressed() -> void:
	get_tree().change_scene_to_file("res://tscn/Notifications.tscn")


func _on_amigos_pressed() -> void:
	get_tree().change_scene_to_file("res://tscn/Friends.tscn")


func refresh_suggestions() -> void:
	if Globals.users_suggestions.size() > 0:
		friend_suggestion_count.text = (
			str(Globals.users_suggestions.size()) + " " + Globals.users_suggestions[0].username
		)
	else:
		friend_suggestion_count.text = ""
		
	var invite_friend_bubble_containers = get_tree().get_nodes_in_group("invite_friend_bubble_container")
	if invite_friend_bubble_containers.size() == 0:
		return
	var invite_friend_bubble_container = invite_friend_bubble_containers.front()

	var background_panels = get_tree().get_nodes_in_group("background_panel")
	if background_panels.size() == 0:
		return
	var background_panel = background_panels.front()

	if background_panel:
		if invite_friend_bubble_container:
			var min_x = background_panel.global_position.x
			var min_y = background_panel.global_position.y
			for child in invite_friend_bubble_container.get_children():
				child.free()
			for users_suggestion in Globals.users_suggestions:
				var new_invite_friend_bubble_card = invite_friend_bubble_card_scene.instantiate()
				new_invite_friend_bubble_card.visible = false;
				invite_friend_bubble_container.add_child(new_invite_friend_bubble_card)
				await new_invite_friend_bubble_card.set_users_suggestion(users_suggestion)
				
				var card_size = new_invite_friend_bubble_card.size
				var max_x = (min_x + background_panel.size.x) - card_size.x
				var max_y = (min_y + background_panel.size.y) - card_size.y
				max_x = max(min_x, max_x)
				max_y = max(min_y, max_y)
				var random_x = randf_range(min_x, max_x)
				var random_y = randf_range(min_y, max_y)
				new_invite_friend_bubble_card.global_position = Vector2(random_x, random_y)
				new_invite_friend_bubble_card.visible = true;

func load_suggestions() -> void:
	var callback = func(response: Array):
		print("Suggestions Success!", response)
		Globals.users_suggestions.clear()
		Globals.users_suggestions.assign(response)
		#await Globals.show_popup(self, "load_suggestions", "suggestions:" + str(Globals.users_suggestions.size()))
		refresh_suggestions()
	var url = Globals.get_api_users_suggestions_url(Globals.user_id)
	HttpRequest.request(url, Globals.headers, HTTPClient.METHOD_GET)
	var http_response = await HttpRequest.request_completed
	var response_code = http_response[1]
	var body = http_response[3]
	Globals.on_request_completed(self, response_code, body, callback)


func show_solicitude_enviada_popup():
	load_suggestions()
	await Globals.show_popup(self, "success", "solicitude enviada")


func _on_add_friend_pressed() -> void:
	if Globals.users_suggestions.size() == 0:
		# if there's no suggestions, try to load some
		load_suggestions()
		return

	var callback = func(response: Dictionary):
		print("Add Friends Success!", response)
		show_solicitude_enviada_popup()
	var url = Globals.get_api_friends_request_url()
	print("_on_add_friend_pressed ", Globals.users_suggestions.size())
	#await Globals.show_popup(self, "_on_add_friend_pressed", "suggestions:" + str(Globals.users_suggestions.size()))
	var friendId = Globals.users_suggestions[0].id
	var data = {
		"userId": Globals.user_id,
		"friendId": friendId,
	}
	var request_body = JSON.stringify(data)
	print("_on_add_friend_pressed ", url, " ", request_body)
	HttpRequest.request(url, Globals.headers, HTTPClient.METHOD_POST, request_body)
	var http_response = await HttpRequest.request_completed
	var response_code = http_response[1]
	var body = http_response[3]
	await Globals.on_request_completed(self, response_code, body, callback)


func refresh_summary() -> void:
	notifications_count.text = ""
	if Globals.notifications_summary.has("unreadNotifications"):
		var unreadNotificationsCount = Globals.notifications_summary.get("unreadNotifications")
		if unreadNotificationsCount:
			notifications_count.text = str(int(unreadNotificationsCount))


func load_summary() -> void:
	var callback = func(response: Dictionary):
		print("Summary Success!", response)
		Globals.notifications_summary = response
		refresh_summary()
	var url = Globals.get_api_notifications_summary_url(Globals.user_id)
	HttpRequest.request(url, Globals.headers, HTTPClient.METHOD_GET)
	var http_response = await HttpRequest.request_completed
	var response_code = http_response[1]
	var body = http_response[3]
	Globals.on_request_completed(self, response_code, body, callback)


func _on_summary_timer_timeout() -> void:
	load_summary()
