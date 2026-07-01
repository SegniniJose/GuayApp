extends Control
class_name Friends

@onready var content = %Content
@onready var solicitudes_count = %SolicitudesCount

@onready var btn_friends = %TabAmigos
@onready var btn_requests = %TabSolicitudes
@onready var btn_invitations = %TabEnviadas

@onready var search_bar = %SearchBar
@onready var search_results_card = %SearchResultsCard

@export var friend_scene: PackedScene = preload("res://tscn/cards/FriendCard.tscn")
@export var pending_outbound_invitation_scene: PackedScene = preload(
	"res://tscn/cards/PendingOutboundInvitationCard.tscn"
)
@export var pending_inbound_request_scene: PackedScene = preload(
	"res://tscn/cards/PendingInboundRequestCard.tscn"
)

@export var no_friends_scene: PackedScene = preload("res://tscn/cards/NoFriendsCard.tscn")
@export var no_pending_outbound_invitations_scene: PackedScene = preload(
	"res://tscn/cards/NoPendingOutboundInvitationsCard.tscn"
)
@export var no_pending_inbound_requests_scene: PackedScene = preload(
	"res://tscn/cards/NoPendingInboundRequestsCard.tscn"
)

var ACTIVE_TAB: StyleBoxFlat = StyleBoxFlat.new()
var INACTIVE_TAB: StyleBoxFlat = StyleBoxFlat.new()

enum TabNames { FRIENDS, REQUESTS, INVITATIONS }

var active_tab: TabNames = TabNames.FRIENDS


func _ready() -> void:
	ACTIVE_TAB.bg_color = Color("ffffff")
	INACTIVE_TAB.bg_color = Color("f1f8ff")
	clear_all_friends()
	await load_friends()
	clear_all_pending_outbound_invitations()
	await load_pending_outbound_invitations()
	clear_all_pending_inbound_requests()
	await load_pending_inbound_requests()
	synch_visible_cards()


func _on_tab_friends_pressed():
	print("_on_tab_friends_pressed")
	active_tab = TabNames.FRIENDS
	#get_tree().call_group("friends", "visible", true)
	#get_tree().call_group("pending_inbound_requests", "visible", false)
	#get_tree().call_group("pending_outbound_invitations", "visible", false)
	synch_button_style(btn_friends)
	synch_visible_cards()


func _on_tab_requests_pressed():
	print("_on_tab_requests_pressed")
	active_tab = TabNames.REQUESTS
	#get_tree().call_group("friends", "visible", false)
	#get_tree().call_group("pending_inbound_requests", "visible", true)
	#get_tree().call_group("pending_outbound_invitations", "visible", false)
	synch_button_style(btn_requests)
	synch_visible_cards()


func _on_tab_invitations_pressed():
	print("_on_tab_invitations_pressed")
	active_tab = TabNames.INVITATIONS
	#get_tree().call_group("friends", "visible", false)
	#get_tree().call_group("pending_inbound_requests", "visible", false)
	#get_tree().call_group("pending_outbound_invitations", "visible", true)
	synch_button_style(btn_invitations)
	synch_visible_cards()


func synch_visible_cards():
	search_results_card.visible = false
	var card_group = "cards"
	match active_tab:
		TabNames.FRIENDS:
			card_group = "friends"
		TabNames.REQUESTS:
			card_group = "pending_inbound_requests"
		TabNames.INVITATIONS:
			card_group = "pending_outbound_invitations"
	synch_card_style(card_group)


func synch_card_style(card_group: String):
	var all_cards = get_tree().get_nodes_in_group("cards")
	for card in all_cards:
		card.visible = false
	var cards = get_tree().get_nodes_in_group(card_group)
	for card in cards:
		card.visible = true


func synch_button_style(button: Button):
	#print("synch_button_style")
	var tabs = get_tree().get_nodes_in_group("tabs")
	for tab in tabs:
		#print("tab ", tab.name, " button ", button.name)
		if tab == button:
			tab.add_theme_stylebox_override("normal", ACTIVE_TAB)
			tab.add_theme_color_override("font_color", Color.BLACK)
		else:
			tab.add_theme_stylebox_override("normal", INACTIVE_TAB)
			tab.add_theme_color_override("font_color", Color.GRAY)


func clear_all_friends():
	get_tree().call_group("friends", "queue_free")


func refresh_friends():
	clear_all_friends()
	if Globals.friends.size() == 0:
		var new_friend = no_friends_scene.instantiate()
		content.add_child(new_friend)
		new_friend.add_to_group("friends")
		new_friend.add_to_group("cards")

	for friend in Globals.friends:
		print("friend ", friend)
		var new_friend = friend_scene.instantiate()
		content.add_child(new_friend)
		new_friend.set_friend(friend)
		new_friend.add_to_group("friends")
		new_friend.add_to_group("cards")
	synch_visible_cards()


func load_friends():
	var callback = func(response: Array):
		print("Friends Success!", response)
		Globals.friends.clear()
		Globals.friends.assign(response)
		refresh_friends()
	var url = Globals.get_api_friends_url(Globals.user_id)
	Globals.http_request_callback(self, url, callback)


func clear_all_pending_outbound_invitations():
	#print("clear_all_pending_outbound_invitations started")
	#for node in get_tree().get_nodes_in_group("pending_outbound_invitations"):
	#print("clear_all_pending_outbound_invitations node ", node)
	#if node != self:
	#node.queue_free()
	get_tree().call_group("pending_outbound_invitations", "queue_free")
	#print("clear_all_pending_outbound_invitations success")


func refresh_pending_outbound_invitations():
	clear_all_pending_outbound_invitations()
	if Globals.pending_outbound_invitations.size() == 0:
		var new_pending_outbound_invitation = no_pending_outbound_invitations_scene.instantiate()
		content.add_child(new_pending_outbound_invitation)
		new_pending_outbound_invitation.add_to_group("pending_outbound_invitations")
		new_pending_outbound_invitation.add_to_group("cards")

	for pending_outbound_invitation in Globals.pending_outbound_invitations:
		print("pending_outbound_invitation ", pending_outbound_invitation)
		var new_pending_outbound_invitation = pending_outbound_invitation_scene.instantiate()
		content.add_child(new_pending_outbound_invitation)
		new_pending_outbound_invitation.set_pending_outbound_invitation(pending_outbound_invitation)
		new_pending_outbound_invitation.add_to_group("pending_outbound_invitations")
		new_pending_outbound_invitation.add_to_group("cards")
	synch_visible_cards()


func load_pending_outbound_invitations():
	var callback = func(response: Array):
		print("Pending Outbound Invitations Success!", response)
		Globals.pending_outbound_invitations.clear()
		Globals.pending_outbound_invitations.assign(response)
		refresh_pending_outbound_invitations()
	var url = Globals.get_api_friends_sent_url(Globals.user_id)
	Globals.http_request_callback(self, url, callback)


func clear_all_pending_inbound_requests():
	get_tree().call_group("pending_inbound_requests", "queue_free")


func refresh_pending_inbound_requests():
	clear_all_pending_inbound_requests()
	if Globals.pending_inbound_requests.size() == 0:
		solicitudes_count.text = ""
	else:
		solicitudes_count.text = str(Globals.pending_inbound_requests.size())

	if Globals.pending_inbound_requests.size() == 0:
		var new_pending_inbound_request = no_pending_inbound_requests_scene.instantiate()
		content.add_child(new_pending_inbound_request)
		new_pending_inbound_request.add_to_group("pending_inbound_requests")
		new_pending_inbound_request.add_to_group("cards")

	for pending_inbound_request in Globals.pending_inbound_requests:
		print("pending_inbound_request ", pending_inbound_request)
		var new_pending_inbound_request = pending_inbound_request_scene.instantiate()
		content.add_child(new_pending_inbound_request)
		new_pending_inbound_request.set_pending_inbound_request(pending_inbound_request)
		new_pending_inbound_request.add_to_group("pending_inbound_requests")
		new_pending_inbound_request.add_to_group("cards")
	synch_visible_cards()


func load_pending_inbound_requests():
	var callback = func(response: Array):
		print("Pending Inbound Requests Success!", response)
		Globals.pending_inbound_requests.clear()
		Globals.pending_inbound_requests.assign(response)
		refresh_pending_inbound_requests()
	var url = Globals.get_api_friends_pending_url(Globals.user_id)
	Globals.http_request_callback(self, url, callback)


func _on_search_btn_pressed() -> void:
	var callback = func(response: Array):
		print("Search Friends Success!", response)
		if response.size() == 0:
			search_results_card.visible = false
		else:
			search_results_card.user_name.text = response[0].username
			search_results_card.user_id.text = response[0].id
			await search_results_card.avatar.set_url(response[0].avatar)
			search_results_card.visible = true
	var query = search_bar.text
	var url = Globals.get_api_users_search_url(query)
	print("_on_search_btn_pressed ", url)
	Globals.http_request_callback(self, url, callback)
