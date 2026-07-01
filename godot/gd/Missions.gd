extends Control
class_name Missions

@onready var missions_header: MissionsHeader = %MissionsHeader

@onready var missions: VBoxContainer = %MissionList

@export var mission_scene: PackedScene = preload("res://tscn/cards/MissionCard.tscn")


func _ready():
	await load_league()
	await load_league_members()
	await load_missions()


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
	for mission in Globals.missions:
		var new_mission = mission_scene.instantiate()
		missions.add_child(new_mission)
		new_mission.set_mission(mission)
		new_mission.add_to_group("missions")


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
