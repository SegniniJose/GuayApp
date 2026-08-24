extends PanelContainer
class_name FriendCard

@onready var avatar: TextureRectUrl = %Avatar
@onready var friend_name: RichTextLabel = %FriendName
@onready var points: RichTextLabel = %Points
@onready var chat_btn: Button = get_node_or_null("Margin/HBox/Chat")

var friend_id: String = ""


func _ready() -> void:
	GuayTheme.apply_panel(self, GuayTheme.panel_surface())
	if chat_btn:
		GuayTheme.apply_button_outline(chat_btn)
		chat_btn.custom_minimum_size = Vector2(44, 44)


func set_friend(friend: Dictionary):
	friend_id = str(friend.get("id", ""))
	var uname = friend.get("username", "Amigo")
	var pts = friend.get("points", 0)
	
	friend_name.text = "[b]%s[/b]" % uname
	points.text = "[font_size=13][color=#475569]ID: %s  •  [color=#10b981]● En línea[/color]  •  %s pts[/color][/font_size]" % [friend_id.substr(0, 6).to_upper() if friend_id.length() >= 6 else friend_id, str(pts)]
	await avatar.set_url(friend.get("avatar", ""))


func _on_chat_pressed() -> void:
	Globals.private_chat_friend_id = friend_id
	get_tree().change_scene_to_file("res://tscn/PrivateChat.tscn")


func _on_avatar_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		Globals.profile_friend_id = friend_id
		get_tree().change_scene_to_file("res://tscn/Profile.tscn")
