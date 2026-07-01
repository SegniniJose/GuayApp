extends PanelContainer
class_name NotificationCard

@onready var avatar: TextureRectUrl = %Avatar
@onready var main: RichTextLabel = %Main
@onready var sub: RichTextLabel = %Sub
@onready var date: RichTextLabel = %Date
@onready var blue_dot: ColorRect = %BlueDot

var notification_type: String = ""
var sender_id: String = ""
var reference_id: String = ""


func set_notification(notification_elt: Dictionary):
	print("set_notification ", notification_elt)
	notification_type = notification_elt.type
	sender_id = notification_elt.senderId
	if notification_elt.has("referenceId"):
		reference_id = notification_elt.referenceId
	else:
		reference_id = ""
	main.text = notification_elt.title
	sub.text = notification_elt.content
	date.text = get_time_ago(notification_elt.createdAt)
	if notification_elt.isRead:
		blue_dot.hide()
	await avatar.set_url(notification_elt.senderAvatar)


static func get_time_ago(unix_timestamp_ms: float) -> String:
	# 1. Convert milliseconds to seconds, then get the difference from current system time
	var created_time_seconds: int = int(unix_timestamp_ms / 1000.0)
	var current_time_seconds: int = int(Time.get_unix_time_from_system())
	var seconds_ago: int = current_time_seconds - created_time_seconds

	# Handle edge case where system clock is slightly out of sync
	if seconds_ago < 0:
		return "ahora mismo"

	# 2. Define time thresholds in seconds
	var minute := 60
	var hour := 3600
	var day := 86400
	var month := 2592000  # 30 days
	var year := 31536000  # 365 days

	# 3. Calculate and return the relative string
	if seconds_ago < minute:
		return "hace unos segundos"
	elif seconds_ago < hour:
		# Adding 'float()' makes the division safe, then 'int()' discards decimals cleanly
		var minutes: int = int(float(seconds_ago) / minute)
		return "hace %d minuto" % minutes if minutes == 1 else "hace %d minutos" % minutes
	elif seconds_ago < day:
		var hours: int = int(float(seconds_ago) / hour)
		return "hace %d hora" % hours if hours == 1 else "hace %d horas" % hours
	elif seconds_ago < month:
		var days: int = int(float(seconds_ago) / day)
		return "hace %d día" % days if days == 1 else "hace %d días" % days
	elif seconds_ago < year:
		var months: int = int(float(seconds_ago) / month)
		return "hace %d mes" % months if months == 1 else "hace %d meses" % months
	else:
		var years: int = int(float(seconds_ago) / year)
		return "hace %d año" % years if years == 1 else "hace %d años" % years


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			handle_notification()


func handle_notification() -> void:
	match notification_type:
		"friend_request":
			get_tree().change_scene_to_file("res://tscn/Friends.tscn")
		"private_message":
			Globals.private_chat_friend_id = sender_id
			get_tree().change_scene_to_file("res://tscn/PrivateChat.tscn")
		"validation":
			Globals.mission_completion_id = reference_id
			get_tree().change_scene_to_file("res://tscn/MissionValidation.tscn")
		_:
			await Globals.show_popup(
				self, "notification", "unknown notification_type :'" + notification_type + "'"
			)
