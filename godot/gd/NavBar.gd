extends PanelContainer
class_name NavBar

@onready var home_btn: Button = %Home
@onready var list_btn: Button = %List
@onready var create_btn: Button = %CreateBtn
@onready var trophy_btn: Button = %Trophy
@onready var profile_btn: Button = %Profile


func _ready() -> void:
	_apply_nav_styles()


func _apply_nav_styles() -> void:
	var cur_scene := ""
	if get_tree().current_scene:
		cur_scene = get_tree().current_scene.scene_file_path

	_style_nav_btn(home_btn, "Inicio", "Dashboard" in cur_scene)
	_style_nav_btn(list_btn, "Misiones", "Missions" in cur_scene or "Leagues" in cur_scene)
	_style_nav_btn(trophy_btn, "Ranking", "Ranking" in cur_scene)
	_style_nav_btn(profile_btn, "Perfil", "Profile" in cur_scene)


func _style_nav_btn(btn: Button, label: String, is_active: bool = false) -> void:
	if btn == null:
		return
	btn.text = label
	btn.flat = true
	btn.add_theme_font_size_override("font_size", 13)
	if is_active:
		btn.add_theme_color_override("font_color", GuayTheme.COLOR_PRIMARY)
		btn.add_theme_color_override("font_hover_color", GuayTheme.COLOR_PRIMARY_DARK)
		btn.add_theme_color_override("font_pressed_color", GuayTheme.COLOR_PRIMARY_DARK)
	else:
		btn.add_theme_color_override("font_color", GuayTheme.COLOR_TEXT_SECONDARY)
		btn.add_theme_color_override("font_hover_color", GuayTheme.COLOR_PRIMARY)
		btn.add_theme_color_override("font_pressed_color", GuayTheme.COLOR_PRIMARY)


func _on_home_pressed() -> void:
	get_tree().change_scene_to_file("res://tscn/Dashboard.tscn")


func _on_list_pressed() -> void:
	if Globals.league_status.get("status", "") == "active" or Globals.league_id != "":
		get_tree().change_scene_to_file("res://tscn/Missions.tscn")
		return
	get_tree().change_scene_to_file("res://tscn/Leagues.tscn")


func _on_create_pressed() -> void:
	if Globals.missions.size() > 0:
		Globals.current_mission_id = Globals.missions[0].id
		get_tree().change_scene_to_file("res://tscn/CameraCapture.tscn")
	else:
		get_tree().change_scene_to_file("res://tscn/Missions.tscn")


func _on_trophy_pressed() -> void:
	get_tree().change_scene_to_file("res://tscn/Ranking.tscn")


func _on_profile_pressed() -> void:
	Globals.profile_friend_id = Globals.user_id
	get_tree().change_scene_to_file("res://tscn/Profile.tscn")
