extends PanelContainer
class_name NavBar

@onready var home_btn: Button = $Icons/Home
@onready var list_btn: Button = $Icons/List
@onready var chat_btn: Button = $Icons/Chat
@onready var trophy_btn: Button = $Icons/Trophy
@onready var profile_btn: Button = $Icons/Profile


func _ready() -> void:
	_apply_nav_styles()


func _apply_nav_styles() -> void:
	add_theme_stylebox_override("panel", GuayTheme.panel_nav())
	custom_minimum_size = Vector2(0, 72)
	_style_nav_btn(home_btn, "🏠", "Inicio")
	_style_nav_btn(list_btn, "🎯", "Misiones")
	_style_nav_btn(chat_btn, "💬", "Social")
	_style_nav_btn(trophy_btn, "🏆", "Ranking")
	_style_nav_btn(profile_btn, "👤", "Perfil")


func _style_nav_btn(btn: Button, icon: String, label: String) -> void:
	btn.text = "%s\n%s" % [icon, label]
	btn.flat = true
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn.add_theme_font_size_override("font_size", 11)
	btn.add_theme_color_override("font_color", GuayTheme.COLOR_TEXT_MUTED)
	btn.add_theme_color_override("font_hover_color", GuayTheme.COLOR_PRIMARY)
	btn.add_theme_color_override("font_pressed_color", GuayTheme.COLOR_PRIMARY)


func _on_home_pressed() -> void:
	get_tree().change_scene_to_file("res://tscn/Dashboard.tscn")


func _on_list_pressed() -> void:
	if Globals.league_status.get("status", "") == "active" or Globals.league_id != "":
		get_tree().change_scene_to_file("res://tscn/Missions.tscn")
		return
	get_tree().change_scene_to_file("res://tscn/Leagues.tscn")


func _on_chat_pressed() -> void:
	get_tree().change_scene_to_file("res://tscn/Chat.tscn")


func _on_trophy_pressed() -> void:
	get_tree().change_scene_to_file("res://tscn/Ranking.tscn")


func _on_profile_pressed() -> void:
	get_tree().change_scene_to_file("res://tscn/Dashboard.tscn")
