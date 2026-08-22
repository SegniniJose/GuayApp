extends Control
class_name Missions

@onready var missions_header: MissionsHeader = %MissionsHeader

@onready var missions: VBoxContainer = %MissionList

@export var mission_scene: PackedScene = preload("res://tscn/cards/MissionCard.tscn")


func _ready():
	_ensure_missions_section_header()
	await load_league()
	await load_league_members()
	await load_missions()
	GuayTheme.fade_in(self)


func _ensure_missions_section_header() -> void:
	# Encabezado "Misiones · Completa retos..." como mockup
	if missions.get_parent() == null:
		return
	var parent = missions.get_parent()
	if parent.get_node_or_null("MissionsSectionHeader") != null:
		return
	var wrap := HBoxContainer.new()
	wrap.name = "MissionsSectionHeader"
	wrap.add_theme_constant_override("separation", 10)
	var left := VBoxContainer.new()
	left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var title := Label.new()
	title.text = "🎯  Misiones"
	GuayTheme.apply_label(title, GuayTheme.FONT_HEADING, GuayTheme.COLOR_TEXT, true)
	var sub := Label.new()
	sub.text = "Completa retos y gana puntos."
	GuayTheme.apply_label(sub, GuayTheme.FONT_CAPTION, GuayTheme.COLOR_TEXT_MUTED)
	left.add_child(title)
	left.add_child(sub)
	var badge := Label.new()
	badge.name = "AvailableBadge"
	badge.text = "  40 disponibles  "
	badge.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	GuayTheme.apply_label(badge, GuayTheme.FONT_CAPTION, GuayTheme.COLOR_ACCENT_ORANGE, true)
	var badge_bg := PanelContainer.new()
	badge_bg.add_theme_stylebox_override("panel", GuayTheme.make_flat(Color("fff7ed"), 20, 0, Color("fed7aa"), 1))
	badge_bg.add_child(badge)
	wrap.add_child(left)
	wrap.add_child(badge_bg)
	parent.add_child(wrap)
	parent.move_child(wrap, missions.get_index())


func refresh_league():
	if Globals.league.size() == 0:
		return
	missions_header.set_league(Globals.league)


func load_league():
	if Globals.league_id == "":
		return
	var callback = func(response: Dictionary):
		print("League Success!", response)
		Globals.league = response
		refresh_league()
	var url = Globals.get_api_leagues_id_url()
	await Globals.http_request_callback(self, url, callback)


func refresh_league_members():
	missions_header.set_members(Globals.league_members)


func load_league_members():
	var callback = func():
		refresh_league_members()
	await Globals.load_league_members(self, callback)


func refresh_missions():
	for child in missions.get_children():
		child.free()
	var available := 0
	for mission in Globals.missions:
		if not mission.get("completed", false):
			available += 1
		var new_mission = mission_scene.instantiate()
		missions.add_child(new_mission)
		new_mission.set_mission(mission)
		new_mission.add_to_group("missions")
	var badge = get_node_or_null("%MissionList/../MissionsSectionHeader/PanelContainer/AvailableBadge")
	if badge == null:
		var hdr = missions.get_parent().get_node_or_null("MissionsSectionHeader")
		if hdr:
			badge = hdr.find_child("AvailableBadge", true, false)
	if badge:
		badge.text = "  %d disponibles  " % max(available, Globals.missions.size())


func load_missions():
	if Globals.league_id == "":
		return
	var callback = func(response: Array):
		print("League Mission Success!", response)
		Globals.missions.clear()
		Globals.missions.assign(response)
		refresh_missions()
	var url = Globals.get_api_missions_url()
	await Globals.http_request_callback(self, url, callback)
