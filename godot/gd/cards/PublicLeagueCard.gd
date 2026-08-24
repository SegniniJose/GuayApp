extends PanelContainer

@onready var league_name: Label = %LeagueName
@onready var member_count: Label = %MemberCount

var public_league_id: String = ""


func set_public_league(public_league: Dictionary):
	league_name.text = str(public_league.get("name", "Liga"))
	var count = public_league.get("memberCount", public_league.get("membersCount", 1))
	if count == null:
		count = 1
	member_count.text = "%d/10 miembros" % int(count)
	public_league_id = str(public_league.get("id", ""))


func _on_join_button_pressed() -> void:
	Globals.league_id = public_league_id
	Globals.post_join_league_and_go_to_dashboard(self)
