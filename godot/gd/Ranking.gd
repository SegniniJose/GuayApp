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
	await load_league_members()

func refresh_league_members():
	for child in further_ranking_list.get_children():
		child.free()

	# 1. Check if we have enough members
	if Globals.league_members.size() < 3:
		three_place_ranking.visible = false
		empty_ranking_card.visible = true
		return
	
	three_place_ranking.visible = true
	empty_ranking_card.visible = false
	
	var sorted_members = Globals.league_members.duplicate()
	sorted_members.sort_custom(func(a, b): return a.points > b.points)
	
	var first_place = sorted_members.pop_front()
	var second_place = sorted_members.pop_front()
	var third_place = sorted_members.pop_front()

	first_place_name.text = first_place.username
	first_place_score.text = str(first_place.points)
	await first_place_avatar.set_url(first_place.avatar)
	
	second_place_name.text = second_place.username
	second_place_score.text = str(second_place.points)
	await second_place_avatar.set_url(second_place.avatar)
	
	third_place_name.text = third_place.username
	third_place_score.text = str(third_place.points)
	await third_place_avatar.set_url(third_place.avatar)

	if sorted_members.size() > 0:
		empty_ranking_card.visible = false
		further_ranking_list.visible = true
	else:
		empty_ranking_card.visible = true
		further_ranking_list.visible = false

	var rank_number:int = 4
	for member in sorted_members:
		var new_ranking = ranking_scene.instantiate()
		further_ranking_list.add_child(new_ranking)
		await new_ranking.set_ranking(rank_number, member)
		rank_number += 1


func load_league_members():
	var callback = func():
		refresh_league_members()
	await Globals.load_league_members(self, callback)
