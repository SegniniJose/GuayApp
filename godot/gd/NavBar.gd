extends PanelContainer
class_name NavBar

## Navbar del mockup: Misiones | Ligas | Crear(+) | Ranking | Perfil

@onready var home_btn: Button = $Icons/Home
@onready var list_btn: Button = $Icons/List
@onready var chat_btn: Button = $Icons/Chat
@onready var trophy_btn: Button = $Icons/Trophy
@onready var profile_btn: Button = $Icons/Profile


func _ready() -> void:
	_apply_nav_styles()
	_highlight_active()


func _highlight_active() -> void:
	var scene := str(get_tree().current_scene.scene_file_path) if get_tree().current_scene else ""
	var active: Button = null
	if scene.find("Missions") >= 0 or scene.find("Camera") >= 0:
		active = home_btn
	elif scene.find("League") >= 0:
		active = list_btn
	elif scene.find("Ranking") >= 0:
		active = trophy_btn
	elif scene.find("Dashboard") >= 0 or scene.find("Profile") >= 0:
		active = profile_btn
	for b in [home_btn, list_btn, trophy_btn, profile_btn]:
		if b == null:
			continue
		var c := GuayTheme.COLOR_PRIMARY if b == active else GuayTheme.COLOR_TEXT_MUTED
		b.add_theme_color_override("font_color", c)


func _apply_nav_styles() -> void:
	add_theme_stylebox_override("panel", GuayTheme.panel_nav())
	custom_minimum_size = Vector2(0, 78)
	# Remapeo visual a mockup (nodos existentes):
	# Home → Misiones, List → Ligas, Chat → Crear(+), Trophy → Ranking, Profile → Perfil
	_style_nav_btn(home_btn, "🎯", "Misiones")
	_style_nav_btn(list_btn, "🏆", "Ligas")
	_style_create_btn(chat_btn)
	_style_nav_btn(trophy_btn, "📊", "Ranking")
	_style_nav_btn(profile_btn, "👤", "Perfil")


func _style_nav_btn(btn: Button, icon: String, label: String) -> void:
	btn.text = "%s\n%s" % [icon, label]
	btn.flat = true
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn.add_theme_font_size_override("font_size", 11)
	btn.add_theme_color_override("font_color", GuayTheme.COLOR_TEXT_MUTED)
	btn.add_theme_color_override("font_hover_color", GuayTheme.COLOR_PRIMARY)
	btn.add_theme_color_override("font_pressed_color", GuayTheme.COLOR_PRIMARY)
	btn.add_theme_color_override("font_focus_color", GuayTheme.COLOR_PRIMARY)


func _style_create_btn(btn: Button) -> void:
	btn.text = "＋\nCrear"
	btn.flat = false
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn.custom_minimum_size = Vector2(64, 64)
	btn.add_theme_font_size_override("font_size", 12)
	btn.add_theme_color_override("font_color", Color.WHITE)
	btn.add_theme_color_override("font_hover_color", Color.WHITE)
	btn.add_theme_color_override("font_pressed_color", Color.WHITE)
	var s := GuayTheme.make_flat(GuayTheme.COLOR_PRIMARY, 32, 10)
	btn.add_theme_stylebox_override("normal", s)
	btn.add_theme_stylebox_override("hover", GuayTheme.make_flat(GuayTheme.COLOR_PRIMARY_DARK, 32, 10))
	btn.add_theme_stylebox_override("pressed", GuayTheme.make_flat(GuayTheme.COLOR_PRIMARY_DARK, 32, 8))


func _on_home_pressed() -> void:
	# Misiones
	if Globals.league_status.get("status", "") == "active" or Globals.league_id != "":
		get_tree().change_scene_to_file("res://tscn/Missions.tscn")
		return
	get_tree().change_scene_to_file("res://tscn/Leagues.tscn")


func _on_list_pressed() -> void:
	# Ligas
	get_tree().change_scene_to_file("res://tscn/Leagues.tscn")


func _on_chat_pressed() -> void:
	# Crear → cámara / completar misión o ligas
	if Globals.league_id != "" and Globals.missions.size() > 0:
		Globals.current_mission_id = str(Globals.missions[0].get("id", ""))
		get_tree().change_scene_to_file("res://tscn/CameraCapture.tscn")
		return
	if Globals.league_id != "":
		get_tree().change_scene_to_file("res://tscn/Missions.tscn")
		return
	get_tree().change_scene_to_file("res://tscn/Leagues.tscn")


func _on_trophy_pressed() -> void:
	get_tree().change_scene_to_file("res://tscn/Ranking.tscn")


func _on_profile_pressed() -> void:
	get_tree().change_scene_to_file("res://tscn/Dashboard.tscn")
