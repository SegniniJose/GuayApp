extends PanelContainer

@onready var league_name: Label = %LeagueName
@onready var member_count: Label = %MemberCount

var public_league_id :String = ""

func set_public_league(public_league: Dictionary):
	print("set_public_league ", public_league)
	league_name.text = public_league.name
	member_count.text = "%s/%s miembros" % [public_league.memberCount, 10]
	public_league_id = public_league.id

func _on_join_button_pressed() -> void:
	Globals.league_id = public_league_id
	Globals.post_join_league_and_go_to_dashboard(self)
