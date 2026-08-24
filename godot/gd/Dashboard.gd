extends Control
class_name Dashboard

@onready var username_label: Label = %Username
@onready var points_label: RichTextLabel = %Points
@onready var photos_label: RichTextLabel = %Photos
@onready var avatar: TextureRectUrl = %Avatar
@onready var profile_card: PanelContainer = %ProfileCard
@onready var private_card: PanelContainer = %PrivateToggleCard
@onready var welcome_panel: PanelContainer = %WelcomePanel
@onready var create_btn: Button = %CreateLeagueButton

@onready var HttpRequest = %HttpRequest
@onready var league_container: VBoxContainer = %LeagueVBoxContainer

var _action_grid: GridContainer
var _progress_card: PanelContainer
var _promo_container: VBoxContainer


func _ready() -> void:
	_apply_dashboard_styles()
	_build_mockup_sections()
	refresh_username_label()
	refresh_points_label()
	await refresh_avatar()
	refresh_photos_label()
	await load_profile()
	await load_photo_count()
	await load_league_status()
	GuayTheme.fade_in(self)


func _apply_dashboard_styles() -> void:
	GuayTheme.apply_panel(profile_card, GuayTheme.panel_surface())
	GuayTheme.apply_panel(private_card, GuayTheme.panel_surface())
	GuayTheme.apply_panel(welcome_panel, GuayTheme.panel_hero())
	GuayTheme.apply_label(username_label, GuayTheme.FONT_HEADING, GuayTheme.COLOR_TEXT, true)
	avatar.custom_minimum_size = Vector2(72, 72)

	# Hero card styling
	var welcome_title = welcome_panel.get_node_or_null("Margin/TextContent/Title")
	var welcome_desc = welcome_panel.get_node_or_null("Margin/TextContent/Desc")
	if welcome_title:
		welcome_title.text = "¡Completa tu primera misión y gana puntos!"
		GuayTheme.apply_label(welcome_title, GuayTheme.FONT_HEADING, Color.WHITE, true)
	if welcome_desc:
		welcome_desc.text = "📷 Haz una foto de una taza de café  ·  ⭐ +10 pts"
		GuayTheme.apply_label(welcome_desc, GuayTheme.FONT_BODY, Color(1, 1, 1, 0.95))

	if create_btn:
		GuayTheme.apply_button_gold(create_btn)
		create_btn.text = "Empezar misión  →"

	var private_title = private_card.get_node_or_null("HBox/TextContent/Title")
	var private_sub = private_card.get_node_or_null("HBox/TextContent/Subtitle")
	if private_title:
		GuayTheme.apply_label(private_title, GuayTheme.FONT_BODY, GuayTheme.COLOR_TEXT, true)
	if private_sub:
		GuayTheme.apply_label(private_sub, GuayTheme.FONT_CAPTION, GuayTheme.COLOR_TEXT_MUTED)

	var toggle: CheckButton = private_card.get_node_or_null("HBox/CheckButton")
	if toggle:
		toggle.button_pressed = Globals.isPrivate
		if not toggle.toggled.is_connected(_on_private_toggled):
			toggle.toggled.connect(_on_private_toggled)

	# Make profile card clickable to view full profile
	profile_card.mouse_filter = Control.MOUSE_FILTER_STOP
	if not profile_card.gui_input.is_connected(_on_profile_card_gui_input):
		profile_card.gui_input.connect(_on_profile_card_gui_input)


func _build_mockup_sections() -> void:
	if league_container.get_node_or_null("MockupGrid") != null:
		return

	# Hide default how it works text panel if present
	var default_how = league_container.get_node_or_null("HowItWorksPanel")
	if default_how:
		default_how.visible = false

	# 1. "Tu progreso" Card
	_progress_card = PanelContainer.new()
	_progress_card.name = "ProgressCard"
	GuayTheme.apply_panel(_progress_card, GuayTheme.panel_surface())
	var prog_margin := MarginContainer.new()
	prog_margin.add_theme_constant_override("margin_left", 16)
	prog_margin.add_theme_constant_override("margin_top", 14)
	prog_margin.add_theme_constant_override("margin_right", 16)
	prog_margin.add_theme_constant_override("margin_bottom", 14)
	var prog_vbox := VBoxContainer.new()
	prog_vbox.add_theme_constant_override("separation", 8)

	var prog_head := HBoxContainer.new()
	var prog_title := Label.new()
	prog_title.text = "Tu progreso"
	GuayTheme.apply_label(prog_title, GuayTheme.FONT_BODY, GuayTheme.COLOR_TEXT, true)
	prog_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var prog_arrow := Label.new()
	prog_arrow.text = "›"
	GuayTheme.apply_label(prog_arrow, GuayTheme.FONT_HEADING, GuayTheme.COLOR_TEXT_MUTED)
	prog_head.add_child(prog_title)
	prog_head.add_child(prog_arrow)

	var prog_body := HBoxContainer.new()
	prog_body.add_theme_constant_override("separation", 14)
	var badge_lvl := Label.new()
	badge_lvl.text = "⭐ Nivel 1"
	GuayTheme.apply_label(badge_lvl, GuayTheme.FONT_LABEL, GuayTheme.COLOR_PRIMARY, true)

	var prog_desc := Label.new()
	prog_desc.text = "Sigue completando misiones para subir de nivel."
	prog_desc.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	prog_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	GuayTheme.apply_label(prog_desc, GuayTheme.FONT_CAPTION, GuayTheme.COLOR_TEXT_SECONDARY)

	var prog_pct := Label.new()
	var pct = 0
	if Globals.points > 0:
		pct = min(100, int((Globals.points % 100)))
	prog_pct.text = "%d%%" % pct
	GuayTheme.apply_label(prog_pct, GuayTheme.FONT_LABEL, GuayTheme.COLOR_PRIMARY, true)

	prog_body.add_child(badge_lvl)
	prog_body.add_child(prog_desc)
	prog_body.add_child(prog_pct)

	prog_vbox.add_child(prog_head)
	prog_vbox.add_child(prog_body)
	prog_margin.add_child(prog_vbox)
	_progress_card.add_child(prog_margin)
	league_container.add_child(_progress_card)

	# 2. 4 Action Cards in 2x2 Grid
	_action_grid = GridContainer.new()
	_action_grid.name = "MockupGrid"
	_action_grid.columns = 2
	_action_grid.add_theme_constant_override("h_separation", 12)
	_action_grid.add_theme_constant_override("v_separation", 12)

	var actions = [
		{"icon": "👥", "title": "Únete a una liga", "sub": "Busca o crea tu propia liga", "scene": "res://tscn/Leagues.tscn"},
		{"icon": "📷", "title": "Completa misiones", "sub": "Haz fotos y gana puntos", "scene": "res://tscn/Missions.tscn"},
		{"icon": "✨", "title": "La comunidad valida", "sub": "Obtén 2 votos positivos", "scene": "res://tscn/MissionValidation.tscn"},
		{"icon": "🏆", "title": "Sube en el ranking", "sub": "Compite y gana recompensas", "scene": "res://tscn/Ranking.tscn"}
	]

	for act in actions:
		var card := PanelContainer.new()
		card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		GuayTheme.apply_panel(card, GuayTheme.panel_surface())
		var m := MarginContainer.new()
		m.add_theme_constant_override("margin_left", 12)
		m.add_theme_constant_override("margin_top", 12)
		m.add_theme_constant_override("margin_right", 12)
		m.add_theme_constant_override("margin_bottom", 12)
		var vb := VBoxContainer.new()
		vb.add_theme_constant_override("separation", 4)

		var ic := Label.new()
		ic.text = act.icon
		GuayTheme.apply_label(ic, GuayTheme.FONT_HEADING)

		var t := Label.new()
		t.text = act.title
		GuayTheme.apply_label(t, GuayTheme.FONT_LABEL, GuayTheme.COLOR_TEXT, true)

		var s := Label.new()
		s.text = act.sub
		s.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		GuayTheme.apply_label(s, GuayTheme.FONT_CAPTION, GuayTheme.COLOR_TEXT_MUTED)

		vb.add_child(ic)
		vb.add_child(t)
		vb.add_child(s)
		m.add_child(vb)
		card.add_child(m)

		var btn_overlay := Button.new()
		btn_overlay.flat = true
		btn_overlay.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		btn_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
		var target_scene = act.scene
		btn_overlay.pressed.connect(func(): get_tree().change_scene_to_file(target_scene))
		card.add_child(btn_overlay)

		_action_grid.add_child(card)

	league_container.add_child(_action_grid)

	# 3. 2 Promo Cards
	_promo_container = VBoxContainer.new()
	_promo_container.name = "PromoContainer"
	_promo_container.add_theme_constant_override("separation", 10)

	var promos = [
		{"icon": "🤝", "title": "Invita a tus amigos", "sub": "Gana +20 pts por cada amigo que se una a GuayGo", "scene": "res://tscn/Friends.tscn"},
		{"icon": "🏆", "title": "Ranking semanal", "sub": "Descubre quiénes son los mejores jugadores", "scene": "res://tscn/Ranking.tscn"}
	]

	for p in promos:
		var p_card := PanelContainer.new()
		GuayTheme.apply_panel(p_card, GuayTheme.panel_surface())
		var pm := MarginContainer.new()
		pm.add_theme_constant_override("margin_left", 14)
		pm.add_theme_constant_override("margin_top", 12)
		pm.add_theme_constant_override("margin_right", 14)
		pm.add_theme_constant_override("margin_bottom", 12)
		var ph := HBoxContainer.new()
		ph.add_theme_constant_override("separation", 12)

		var pi := Label.new()
		pi.text = p.icon
		GuayTheme.apply_label(pi, GuayTheme.FONT_TITLE)

		var pvb := VBoxContainer.new()
		pvb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var pt := Label.new()
		pt.text = p.title
		GuayTheme.apply_label(pt, GuayTheme.FONT_BODY, GuayTheme.COLOR_TEXT, true)
		var ps := Label.new()
		ps.text = p.sub
		GuayTheme.apply_label(ps, GuayTheme.FONT_CAPTION, GuayTheme.COLOR_TEXT_SECONDARY)
		pvb.add_child(pt)
		pvb.add_child(ps)

		var parrow := Label.new()
		parrow.text = "›"
		GuayTheme.apply_label(parrow, GuayTheme.FONT_HEADING, GuayTheme.COLOR_PRIMARY)

		ph.add_child(pi)
		ph.add_child(pvb)
		ph.add_child(parrow)
		pm.add_child(ph)
		p_card.add_child(pm)

		var p_btn := Button.new()
		p_btn.flat = true
		p_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		p_btn.set_anchors_preset(Control.PRESET_FULL_RECT)
		var target_scene = p.scene
		p_btn.pressed.connect(func(): get_tree().change_scene_to_file(target_scene))
		p_card.add_child(p_btn)

		_promo_container.add_child(p_card)

	league_container.add_child(_promo_container)


func _on_profile_card_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		Globals.profile_friend_id = Globals.user_id
		get_tree().change_scene_to_file("res://tscn/Profile.tscn")


func _on_private_toggled(button_pressed: bool) -> void:
	Globals.isPrivate = button_pressed


func refresh_photos_label() -> void:
	photos_label.text = GuayTheme.stat_bbcode(Globals.photo_count, "fotos", "#ffc107")


func refresh_points_label() -> void:
	points_label.text = GuayTheme.stat_bbcode(Globals.points, "puntos", "#0066ff")


func refresh_avatar() -> void:
	await avatar.set_url(Globals.avatar)


func refresh_username_label() -> void:
	username_label.text = Globals.username if Globals.username != "" else "Jugador"


func load_profile() -> void:
	var callback = func(response: Dictionary):
		Globals.set_profile(response)
		refresh_username_label()
		refresh_points_label()
		await refresh_avatar()
	var url = Globals.get_api_users_profile_url(Globals.user_id, Globals.user_id)
	HttpRequest.request(url, Globals.headers, HTTPClient.METHOD_GET)
	var http_response = await HttpRequest.request_completed
	Globals.on_request_completed(self, http_response[1], http_response[3], callback)


func load_photo_count() -> void:
	var callback = func(response: Dictionary):
		Globals.photo_count = response.count
		refresh_photos_label()
	var url = Globals.get_api_users_photo_count_url(Globals.user_id)
	HttpRequest.request(url, Globals.headers, HTTPClient.METHOD_GET)
	var http_response = await HttpRequest.request_completed
	Globals.on_request_completed(self, http_response[1], http_response[3], callback)


func refresh_league_status() -> void:
	pass


func load_league_status() -> void:
	if Globals.league_id == "":
		return
	var callback = func(response: Dictionary):
		Globals.league_status = response
		refresh_league_status()
	var url = Globals.get_api_leagues_status_url()
	await Globals.http_request_callback(self, url, callback)


func _on_create_league_button_pressed() -> void:
	if Globals.missions.size() > 0:
		Globals.current_mission_id = Globals.missions[0].id
		get_tree().change_scene_to_file("res://tscn/CameraCapture.tscn")
		return
	if Globals.league_status.get("status", "") == "active" or Globals.league_id != "":
		get_tree().change_scene_to_file("res://tscn/Missions.tscn")
		return
	get_tree().change_scene_to_file("res://tscn/Leagues.tscn")
