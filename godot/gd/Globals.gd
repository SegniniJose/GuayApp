extends Resource
class_name Globals

static var headers: Array[String] = ["Content-Type: application/json"]

#change this URL to be the actual server
#static var base_url_dev = "https://d583b40b-1cae-452e-ac12-74ac5903d7b0-00-1enao8eqex4ts.worf.replit.dev"
#static var base_url_prod = "https://d583b40b-1cae-452e-ac12-74ac5903d7b0-00-1enao8eqex4ts.worf.replit.dev"
static var base_url_dev = "https://guayapp.onrender.com"
static var base_url_prod = "https://guayapp.onrender.com"
static var users_suggestions_limit = "5"
static var base_url
static var user_id: String = ""
static var username: String = ""
static var email: String = ""
static var league_id: String = ""
static var avatar: String = ""
static var points: int = 0
static var photo_count: int = 0
static var isPrivate: bool = true
static var users_suggestions: Array[Dictionary] = []
static var notifications_summary: Dictionary = {}
static var notifications: Array[Dictionary] = []
static var friends: Array[Dictionary] = []
static var pending_outbound_invitations: Array[Dictionary] = []
static var pending_inbound_requests: Array[Dictionary] = []
static var private_chat_friend_id = ""
static var private_chats: Array[Dictionary] = []
static var league_status: Dictionary = {}
static var league: Dictionary = {}
static var league_members: Array[Dictionary] = []
static var league_chats: Array[Dictionary] = []
static var missions: Array[Dictionary] = []
static var current_mission_id = ""
static var stories: Array[Dictionary] = []
static var mission_completion_id = ""
static var votes: Dictionary = {}
static var public_leagues: Array[Dictionary] = []
static var profile_friend_id = ""
static var profile: Dictionary = {}

static func _static_init():
	if OS.has_feature("debug"):
		base_url = base_url_dev
	else:
		base_url = base_url_prod
	print("Static URL initialized to: ", base_url)


static func get_api_auth_register_url():
	return "%s/api/auth/register" % [base_url]



static func get_global_api_users_profile_url():
	return get_api_users_profile_url(profile_friend_id, user_id)
	
static func get_api_users_profile_url(userId: String, viewerId: String):
	return "%s/api/users/%s/profile?viewerId=%s" % [base_url, userId, viewerId]


static func get_api_users_photo_count_url(userId: String):
	return "%s/api/users/%s/photo-count" % [base_url, userId]


static func get_api_users_suggestions_url(userId: String):
	return "%s/api/users/%s/suggestions?limit=%s" % [base_url, userId, users_suggestions_limit]


static func get_api_leagues_code_url(code: String):
	return "%s/api/leagues/code/%s" % [base_url, code]


static func get_api_leagues_id_url():
	return "%s/api/leagues/id/%s" % [base_url, league_id]


static func get_api_leagues_join_url():
	return "%s/api/leagues/%s/join" % [base_url, league_id]


static func get_api_leagues_status_url():
	return "%s/api/leagues/%s/status" % [base_url, league_id]


static func get_api_leagues_members_url():
	return "%s/api/leagues/%s/members" % [base_url, league_id]


static func get_api_leagues_post_url():
	return "%s/api/leagues" % [base_url]


static func get_api_missions_url():
	return "%s/api/missions/%s?userId=%s" % [base_url, league_id, user_id]


static func get_api_missions_complete_post_url():
	return "%s/api/missions/%s/complete" % [base_url, current_mission_id]


static func get_api_messages_url():
	return "%s/api/messages/%s" % [base_url, league_id]


static func get_api_messages_post_url():
	return "%s/api/messages" % [base_url]


static func get_api_validation_url():
	return "%s/api/validation/%s" % [base_url, league_id]


static func get_api_validation_photo_url(completionId: String):
	return "%s/api/validation/photo/%s" % [base_url, completionId]


static func get_api_collag_urle():
	return "%s/api/collage/%s" % [base_url, league_id]


static func get_api_messages_text_url():
	return "%s/api/messages/text/%s" % [base_url, league_id]


static func get_api_votes_url():
	return "%s/api/votes" % [base_url]


static func get_api_stories_url():
	return "%s/api/stories/%s?userId=%s" % [base_url, league_id, user_id]


static func get_api_tracks_url():
	return "%s/api/tracks" % [base_url]


static func get_api_tracks_id_url(userId: String):
	return "%s/api/tracks/%s" % [base_url, userId]


static func get_api_users_search_url(query: String):
	return "%s/api/users/search?query=%s&userId=%s" % [base_url, query, user_id]


static func get_api_friends_accept_url():
	return "%s/api/friends/accept" % [base_url]


static func get_api_friends_reject_url():
	return "%s/api/friends/reject" % [base_url]


static func get_api_friends_url(userId: String):
	return "%s/api/friends/%s" % [base_url, userId]


static func get_api_friends_pending_url(userId: String):
	return "%s/api/friends/%s/pending" % [base_url, userId]


static func get_api_friends_sent_url(userId: String):
	return "%s/api/friends/%s/sent" % [base_url, userId]


static func get_api_friends_request_url():
	return "%s/api/friends/request" % [base_url]


static func get_api_messages_private_url(userId: String, friendId: String):
	return "%s/api/messages/private/%s/%s" % [base_url, userId, friendId]


static func get_api_messages_private_post_url():
	return "%s/api/messages/private" % [base_url]


static func get_api_messages_unread_url(userId: String):
	return "%s/api/messages/unread/%s" % [base_url, userId]


static func get_api_leagues_public_url():
	return "%s/api/leagues/public" % [base_url]


static func get_api_events_special_url():
	return "%s/api/events/special" % [base_url]


static func get_api_leagues_pack_url():
	return "%s/api/leagues/%s/pack" % [base_url, league_id]


static func get_api_leagues_collage_url():
	return "%s/api/leagues/%s/collage" % [base_url, league_id]


static func get_api_notifications_url(userId: String):
	return "%s/api/notifications/%s" % [base_url, userId]


static func get_api_notifications_count_url(userId: String):
	return "%s/api/notifications/%s/count" % [base_url, userId]


static func get_api_notifications_summary_url(userId: String):
	return "%s/api/notifications/%s/summary" % [base_url, userId]


static func set_profile(response: Dictionary):
	Globals.user_id = get_or_default(response, "id", Globals.user_id, "")
	Globals.username = get_or_default(response, "username", Globals.username, "")
	Globals.email = get_or_default(response, "email", Globals.email, "")
	Globals.league_id = get_or_default(response, "leagueId", Globals.league_id, "")
	Globals.avatar = get_or_default(response, "avatar", Globals.avatar, "")
	Globals.points = get_or_default(response, "points", Globals.points, 0)
	Globals.isPrivate = get_or_default(response, "isPrivate", Globals.isPrivate, true)


static func get_or_default(response: Dictionary, key: String, current_val, default_val):
	var val = response.get(key, current_val)
	if val == null:
		return default_val
	else:
		return val


static func erase_all():
	Globals.user_id = ""
	Globals.username = ""
	Globals.email = ""
	Globals.league_id = ""
	Globals.avatar = ""
	Globals.points = 0
	Globals.isPrivate = true
	Globals.users_suggestions = []
	Globals.notifications_summary = {}
	Globals.notifications = []
	Globals.friends = []
	Globals.pending_outbound_invitations = []
	Globals.pending_inbound_requests = []
	Globals.private_chat_friend_id = ""
	Globals.private_chats = []
	Globals.league_status = {}
	Globals.league = {}
	Globals.league_members = []
	Globals.league_chats = []
	Globals.missions = []
	Globals.current_mission_id = ""
	Globals.stories = []
	Globals.mission_completion_id = ""
	Globals.votes = {}
	Globals.public_leagues = []
	Globals.profile_friend_id = ""
	Globals.profile = {}

static func show_error_popup(requester: Node, message: String, button_to_shake: Node = null):
	var dialog = AcceptDialog.new()
	dialog.title = "Atención"
	dialog.dialog_text = message

	requester.add_child(dialog)
	dialog.popup_centered()

	if button_to_shake:
		shake_node(button_to_shake)


static func show_popup(
	requester: Node, title: String, message: String, button_to_shake: Node = null
):
	var dialog = AcceptDialog.new()
	dialog.title = title
	dialog.dialog_text = message

	requester.add_child(dialog)
	dialog.popup_centered()

	if button_to_shake:
		shake_node(button_to_shake)


static func shake_node(node: Control) -> void:
	if not node:
		return
	var tween: Tween = node.get_tree().create_tween()
	var orig_x: float = node.position.x

	for i in range(4):
		tween.tween_property(node, "position:x", orig_x + 10, 0.05)
		tween.tween_property(node, "position:x", orig_x - 10, 0.05)

	tween.tween_property(node, "position:x", orig_x, 0.05)


static func on_request_completed(
	requester: Node, response_code: int, body: PackedByteArray, callback: Callable
):
	var text = body.get_string_from_utf8()
	var json: JSON = JSON.new()
	var error: Error = json.parse(text)
	if error != OK:
		var error_msg: String = (
			"JSON Parse Error: %s at line %d '%s'"
			% [json.get_error_message(), json.get_error_line(), text]
		)
		push_error(error_msg)
		await Globals.show_error_popup(requester, error_msg, null)

	if response_code == 200:
		var data = json.get_data()
		await callback.call(data)
	else:
		var error_msg = "Error de conexión"
		var response = json.get_data()
		if response and response is Dictionary and response.has("error"):
			error_msg = response["error"]

		await Globals.show_error_popup(requester, error_msg, null)


static func http_request_callback(requester: Node, url: String, callback: Callable):
	var http_request = HTTPRequest.new()
	requester.add_child(http_request)
	http_request.request(url, Globals.headers, HTTPClient.METHOD_GET)
	var http_response = await http_request.request_completed
	http_request.queue_free()
	var response_code = http_response[1]
	var body = http_response[3]
	await Globals.on_request_completed(requester, response_code, body, callback)


static func http_post_callback(requester: Node, url: String, data: Dictionary, callback: Callable):
	var http_request = HTTPRequest.new()
	requester.add_child(http_request)
	var request_body = JSON.stringify(data)
	http_request.request(url, Globals.headers, HTTPClient.METHOD_POST, request_body)
	var http_response = await http_request.request_completed
	http_request.queue_free()
	var response_code = http_response[1]
	var body = http_response[3]
	await Globals.on_request_completed(requester, response_code, body, callback)


static func timestamp_to_string(timestamp) -> String:
	var timestamp_seconds: int = int(timestamp / 1000.0)
	var datetime: Dictionary = Time.get_datetime_dict_from_unix_time(timestamp_seconds)
	print("timestamp_to_string ", timestamp, " ", datetime)
	var time_text: String = (
		"%04d-%02d-%02d %02d:%02d:%02d"
		% [
			datetime.year,
			datetime.month,
			datetime.day,
			datetime.hour,
			datetime.minute,
			datetime.second
		]
	)
	return time_text

static func load_league_members(requester: Node, after_load_callback:Callable):
	if Globals.league_id == "":
		return
	var callback = func(response: Array):
		print("League Member Success!", response)
		Globals.league_members.clear()
		Globals.league_members.assign(response)
		after_load_callback.call()
	var url = Globals.get_api_leagues_members_url()
	await Globals.http_request_callback(requester, url, callback)

static func post_join_league_and_go_to_dashboard(requester: Node) -> void:
	var callback = func(response: Dictionary):
		print("post_join_league", response)
		requester.get_tree().change_scene_to_file("res://tscn/Dashboard.tscn")
	var data = {
		"userId": Globals.user_id,
	}
	var url = Globals.get_api_leagues_join_url()
	await Globals.http_post_callback(requester, url, data, callback)
