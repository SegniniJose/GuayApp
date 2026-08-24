extends Control

@onready var empty_ranking_card: PanelContainer = %EmptyRankingCard
@onready var three_place_ranking: PanelContainer = %ThreePlaceRanking
@onready var further_ranking_list: VBoxContainer = %FurtherRankingList

@onready var first_place_name: Label = %FirstPlaceName
@onready var first_place_score: Label = %FirstPlaceScore
@onready var first_place_avatar: TextureRectUrl = %FirstPlaceAvatar

@onready var second_place_name: Label = %SecondPlaceName
@onready var second_place_score: Label = %SecondPlaceScore
@onready var second_place_avatar: TextureRectUrl = %SecondPlaceAvatar

@onready var third_place_name: Label = %ThirdPlaceName
@onready var third_place_score: Label = %ThirdPlaceScore
@onready var third_place_avatar: TextureRectUrl = %ThirdPlaceAvatar

@export var ranking_scene: PackedScene = preload("res://tscn/cards/RankingCard.tscn")

func _ready() -> void:
	_apply_ranking_styles()
	await load_league_members()
	GuayTheme.fade_in(self)


func _apply_ranking_styles() -> void:
	if three_place_ranking:
		GuayTheme.apply_panel(three_place_ranking, GuayTheme.panel_surface())
	if empty_ranking_card:
		GuayTheme.apply_panel(empty_ranking_card, GuayTheme.panel_surface())
	for lbl in [first_place_name, second_place_name, third_place_name]:
		if lbl:
			GuayTheme.apply_label(lbl, GuayTheme.FONT_BODY, GuayTheme.COLOR_TEXT, true)
	for lbl in [first_place_score, second_place_score, third_place_score]:
		if lbl:
			GuayTheme.apply_label(lbl, GuayTheme.FONT_LABEL, GuayTheme.COLOR_PRIMARY, true)


func refresh_league_members():
	for child in further_ranking_list.get_children():
		child.free()

	var members_list = Globals.league_members.duplicate()
	if members_list.is_empty():
		# Add current user if available
		if Globals.user_id != "":
			members_list.append({"id": Globals.user_id, "username": Globals.username if Globals.username != "" else "Tú", "points": Globals.points, "avatar": Globals.avatar})

	if members_list.size() < 1:
		three_place_ranking.visible = false
		empty_ranking_card.visible = true
		return
	
	three_place_ranking.visible = true
	empty_ranking_card.visible = false
	
	var sorted_members = members_list.duplicate()
	sorted_members.sort_custom(func(a, b): return a.get("points", 0) > b.get("points", 0))
	
	var first_place = sorted_members.pop_front() if sorted_members.size() > 0 else {"username": "Klk", "points": 520, "avatar": ""}
	var second_place = sorted_members.pop_front() if sorted_members.size() > 0 else {"username": "María", "points": 470, "avatar": ""}
	var third_place = sorted_members.pop_front() if sorted_members.size() > 0 else {"username": "Alex", "points": 430, "avatar": ""}

	first_place_name.text = first_place.get("username", "")
	first_place_score.text = "%s pts" % str(first_place.get("points", 0))
	await first_place_avatar.set_url(first_place.get("avatar", ""))
	
	second_place_name.text = second_place.get("username", "")
	second_place_score.text = "%s pts" % str(second_place.get("points", 0))
	await second_place_avatar.set_url(second_place.get("avatar", ""))
	
	third_place_name.text = third_place.get("username", "")
	third_place_score.text = "%s pts" % str(third_place.get("points", 0))
	await third_place_avatar.set_url(third_place.get("avatar", ""))

	if sorted_members.size() > 0:
		empty_ranking_card.visible = false
		further_ranking_list.visible = true
	else:
		further_ranking_list.visible = false

	var rank_number: int = 4
	for member in sorted_members:
		var new_ranking = ranking_scene.instantiate()
		further_ranking_list.add_child(new_ranking)
		await new_ranking.set_ranking(rank_number, member)
		rank_number += 1


func load_league_members():
	var callback = func():
		refresh_league_members()
	await Globals.load_league_members(self, callback)
