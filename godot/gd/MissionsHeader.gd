extends PanelContainer
class_name MissionsHeader

@onready var league_name_label: Label = %LeagueNameLabel
@onready var join_code_label: Label = %JoinCodeLabel
@onready var members_label: Label = %MembersLabel
@onready var date_label: Label = %DateLabel


func _ready() -> void:
	GuayTheme.apply_panel(self, GuayTheme.panel_surface())
	GuayTheme.apply_label(league_name_label, GuayTheme.FONT_HEADING, GuayTheme.COLOR_TEXT, true)
	GuayTheme.apply_label(join_code_label, GuayTheme.FONT_BODY, GuayTheme.COLOR_PRIMARY, true)
	GuayTheme.apply_label(members_label, GuayTheme.FONT_CAPTION, GuayTheme.COLOR_TEXT_SECONDARY)
	GuayTheme.apply_label(date_label, GuayTheme.FONT_CAPTION, GuayTheme.COLOR_TEXT_MUTED)


func set_league(league: Dictionary):
	print("set_league ", league)
	league_name_label.text = league.get("name", "Liga")
	join_code_label.text = league.get("code", "")

	var start = league.get("startDate", "")
	if typeof(start) == TYPE_STRING and start != "":
		var datetime_dict = Time.get_datetime_dict_from_datetime_string(start, false)
		date_label.text = "%04d-%02d-%02d" % [datetime_dict.year, datetime_dict.month, datetime_dict.day]
	else:
		date_label.text = Time.get_date_string_from_system()


func set_members(members: Array[Dictionary]):
	print("set_members ", members)
	members_label.text = "%d Miembros" % [members.size()]


func _on_copy_button_pressed() -> void:
	var original_text = join_code_label.text
	DisplayServer.clipboard_set(original_text)
	join_code_label.text = "¡Copiado!"
	await get_tree().create_timer(1.5).timeout
	join_code_label.text = original_text
