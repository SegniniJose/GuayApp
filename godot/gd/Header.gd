extends Node
class_name Header

@onready var friend_suggestion_count: RichTextLabel = %FriendSuggestionCount
@onready var notifications_count: RichTextLabel = %NotificationsCount
@onready var amigos_btn: LinkButton = $HBox/Amigos
@onready var exit_btn: Button = $HBox/ExitButton
@onready var HttpRequest = %HttpRequest

@export var invite_friend_bubble_card_scene: PackedScene = preload("res://tscn/cards/InviteFriendBubbleCard.tscn")


func _ready() -> void:
	_apply_header_styles()
	await load_suggestions()
	await load_summary()


func _apply_header_styles() -> void:
	GuayTheme.apply_link(amigos_btn)
	amigos_btn.text = "👥 Amigos"
	GuayTheme.apply_button_ghost(exit_btn, GuayTheme.COLOR_DANGER)
	exit_btn.text = "Salir"
	exit_btn.add_theme_font_size_override("font_size", GuayTheme.FONT_LABEL)
	friend_suggestion_count.add_theme_color_override("default_color", GuayTheme.COLOR_PRIMARY)
	notifications_count.add_theme_color_override("default_color", GuayTheme.COLOR_ACCENT_GOLD)


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
		friend_suggestion_count.text = str(Globals.users_suggestions.size())
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

	if background_panel and invite_friend_bubble_container:
		var min_x = background_panel.global_position.x + 16
		var min_y = background_panel.global_position.y + 120
		for child in invite_friend_bubble_container.get_children():
			child.free()
		for users_suggestion in Globals.users_suggestions:
			var new_invite_friend_bubble_card = invite_friend_bubble_card_scene.instantiate()
			new_invite_friend_bubble_card.visible = false
			invite_friend_bubble_container.add_child(new_invite_friend_bubble_card)
			await new_invite_friend_bubble_card.set_users_suggestion(users_suggestion)

			var card_size = new_invite_friend_bubble_card.size
			var max_x = (min_x + background_panel.size.x) - card_size.x - 16
			var max_y = (min_y + background_panel.size.y) - card_size.y - 100
			max_x = max(min_x, max_x)
			max_y = max(min_y, max_y)
			var random_x = randf_range(min_x, max_x)
			var random_y = randf_range(min_y, max_y)
			new_invite_friend_bubble_card.global_position = Vector2(random_x, random_y)
			new_invite_friend_bubble_card.visible = true


func load_suggestions() -> void:
	if Globals.user_id == "":
		return
	var callback = func(response: Array):
		Globals.users_suggestions.clear()
		Globals.users_suggestions.assign(response)
		refresh_suggestions()
	var url = Globals.get_api_users_suggestions_url(Globals.user_id)
	HttpRequest.request(url, Globals.headers, HTTPClient.METHOD_GET)
	var http_response = await HttpRequest.request_completed
	await Globals.on_request_completed(self, http_response[1], http_response[3], callback)


func show_solicitude_enviada_popup() -> void:
	load_suggestions()
	await Globals.show_popup(self, "Listo", "Solicitud de amistad enviada")


func _on_add_friend_pressed() -> void:
	if Globals.users_suggestions.size() == 0:
		load_suggestions()
		return

	var callback = func(_response: Dictionary):
		show_solicitude_enviada_popup()
	var data = {
		"userId": Globals.user_id,
		"friendId": Globals.users_suggestions[0].id,
	}
	var url = Globals.get_api_friends_request_url()
	HttpRequest.request(url, Globals.headers, HTTPClient.METHOD_POST, JSON.stringify(data))
	var http_response = await HttpRequest.request_completed
	await Globals.on_request_completed(self, http_response[1], http_response[3], callback)


func refresh_summary() -> void:
	notifications_count.text = ""
	if Globals.notifications_summary.has("unreadNotifications"):
		var unread_count = Globals.notifications_summary.get("unreadNotifications")
		if unread_count:
			notifications_count.text = str(int(unread_count))


func load_summary() -> void:
	if Globals.user_id == "":
		return
	var callback = func(response: Dictionary):
		Globals.notifications_summary = response
		refresh_summary()
	var url = Globals.get_api_notifications_summary_url(Globals.user_id)
	HttpRequest.request(url, Globals.headers, HTTPClient.METHOD_GET)
	var http_response = await HttpRequest.request_completed
	await Globals.on_request_completed(self, http_response[1], http_response[3], callback)


func _on_summary_timer_timeout() -> void:
	load_summary()
