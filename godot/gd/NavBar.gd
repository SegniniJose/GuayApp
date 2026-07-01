extends Node
class_name NavBar


func _ready() -> void:
	pass


func _on_home_pressed() -> void:
	get_tree().change_scene_to_file("res://tscn/Dashboard.tscn")


func _on_list_pressed() -> void:
	if Globals.league_status:
		if Globals.league_status.status == "active":
			get_tree().change_scene_to_file("res://tscn/Missions.tscn")
			return
	get_tree().change_scene_to_file("res://tscn/Leagues.tscn")


func _on_chat_pressed() -> void:
	get_tree().change_scene_to_file("res://tscn/Chat.tscn")


func _on_trophy_pressed() -> void:
	get_tree().change_scene_to_file("res://tscn/Ranking.tscn")
