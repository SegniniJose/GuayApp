extends PanelContainer
class_name MissionsHeader

@onready var league_name_label: Label = %LeagueNameLabel
@onready var join_code_label: Label = %JoinCodeLabel
@onready var members_label: Label = %MembersLabel
@onready var date_label: Label = %DateLabel


func set_league(league: Dictionary):
	print("set_league ", league)
	league_name_label.text = league.name
	join_code_label.text = league.code

	var datetime_dict = Time.get_datetime_dict_from_datetime_string(league.startDate, false)
	var date_only = "%04d-%02d-%02d" % [datetime_dict.year, datetime_dict.month, datetime_dict.day]
	date_label.text = date_only


func set_members(members: Array[Dictionary]):
	print("set_members ", members)
	members_label.text = "%d Miembros" % [members.size()]


func _on_copy_button_pressed() -> void:
	var original_text = join_code_label.text
	DisplayServer.clipboard_set(original_text)
	join_code_label.text = "¡Copiado!"
	await get_tree().create_timer(1.5).timeout
	join_code_label.text = original_text
