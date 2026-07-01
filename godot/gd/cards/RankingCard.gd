extends MarginContainer

@onready var you_tag: PanelContainer = %YouTag

@onready var rank: Label = %RankLabel
@onready var avatar: TextureRectUrl = %Avatar
@onready var username: Label = %UsernameLabel
@onready var points: Label = %PointsLabel

func set_ranking(rank_number:int, ranking: Dictionary):
	print("set_ranking ", rank_number, " ", ranking)
	if ranking.id == Globals.user_id:
		you_tag.visible = true
	else:
		you_tag.visible = false
	rank.text = str(rank_number)
	username.text = ranking.username
	points.text = str(ranking.points)
	await avatar.set_url(ranking.avatar)
