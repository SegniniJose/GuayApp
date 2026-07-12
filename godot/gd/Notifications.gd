extends Control
class_name Notifications

@onready var subtitle: RichTextLabel = %Subtitle
@onready var items: VBoxContainer = %ItemsVBox

@onready var HttpRequest = %HttpRequest
@export var notification_scene: PackedScene = preload("res://tscn/cards/NotificationCard.tscn")


func _ready() -> void:
	refresh_subtitle()
	clear_all_notifications()
	load_notifications()


func refresh_subtitle() -> void:
	subtitle.text = ""
	if Globals.notifications_summary.has("unreadNotifications"):
		var unreadNotificationsCount = Globals.notifications_summary.get("unreadNotifications")
		if unreadNotificationsCount:
			subtitle.text = str(int(unreadNotificationsCount)) + " sin leer"


func clear_all_notifications():
	get_tree().call_group("notifications", "queue_free")


func refresh_notifications():
	clear_all_notifications()
	for notification_elt in Globals.notifications:
		print("notification_elt ", notification_elt)
		var new_notif = notification_scene.instantiate()
		items.add_child(new_notif)
		new_notif.set_notification(notification_elt)
		new_notif.add_to_group("notifications")


func load_notifications() -> void:
	var callback = func(response: Array):
		print("Notifications Success!", response)
		Globals.notifications.clear()
		Globals.notifications.assign(response)
		refresh_notifications()
	var url = Globals.get_api_notifications_url(Globals.user_id)
	HttpRequest.request(url, Globals.headers, HTTPClient.METHOD_GET)
	var http_response = await HttpRequest.request_completed
	var response_code = http_response[1]
	var body = http_response[3]
	Globals.on_request_completed(self, response_code, body, callback)


func _on_mark_all_btn_pressed() -> void:
	var callback = func(_response: Dictionary):
		Globals.notifications_summary = {"unreadNotifications": 0}
		refresh_subtitle()
		for i in Globals.notifications.size():
			Globals.notifications[i]["isRead"] = true
		refresh_notifications()
	var url = Globals.get_api_notifications_mark_all_read_url(Globals.user_id)
	await Globals.http_post_callback(self, url, {}, callback)
