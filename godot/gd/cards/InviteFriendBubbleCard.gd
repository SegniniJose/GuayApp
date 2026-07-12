extends PanelContainer
class_name InviteFriendBubbleCard

@onready var avatar: TextureRectUrl = %Avatar
@onready var friend_name: RichTextLabel = %FriendName

var friend_id: String = ""


func _ready() -> void:
	add_theme_stylebox_override("panel", GuayTheme.panel_surface())
	custom_minimum_size = Vector2(180, 56)
	friend_name.add_theme_color_override("default_color", GuayTheme.COLOR_TEXT)
	friend_name.add_theme_font_size_override("normal_font_size", GuayTheme.FONT_LABEL)


func set_users_suggestion(users_suggestion: Dictionary) -> void:
	friend_id = users_suggestion.id
	friend_name.text = "[b]%s[/b]\n[font_size=11][color=#6366f1]Toca para invitar[/color][/font_size]" % users_suggestion.username
	await avatar.set_url(users_suggestion.avatar)


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		var callback = func(_response: Dictionary):
			get_tree().change_scene_to_file("res://tscn/Dashboard.tscn")
		var data = {"userId": Globals.user_id, "friendId": friend_id}
		await Globals.http_post_callback(self, Globals.get_api_friends_request_url(), data, callback)
