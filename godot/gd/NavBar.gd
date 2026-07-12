extends PanelContainer
class_name NavBar

@onready var home_btn: Button = $Icons/Home
@onready var list_btn: Button = $Icons/List
@onready var chat_btn: Button = $Icons/Chat
@onready var trophy_btn: Button = $Icons/Trophy


func _ready() -> void:
	_apply_nav_styles()


func _apply_nav_styles() -> void:
	add_theme_stylebox_override("panel", GuayTheme.panel_nav())
	for btn in [home_btn, list_btn, chat_btn, trophy_btn]:
		btn.add_theme_font_size_override("font_size", 28)
		btn.flat = true


func _on_home_pressed() -> void:
	get_tree().change_scene_to_file("res://tscn/Dashboard.tscn")


func _on_list_pressed() -> void:
	if Globals.league_status.get("status", "") == "active":
		get_tree().change_scene_to_file("res://tscn/Missions.tscn")
		return
	get_tree().change_scene_to_file("res://tscn/Leagues.tscn")


func _on_chat_pressed() -> void:
	get_tree().change_scene_to_file("res://tscn/Chat.tscn")


func _on_trophy_pressed() -> void:
	get_tree().change_scene_to_file("res://tscn/Ranking.tscn")
