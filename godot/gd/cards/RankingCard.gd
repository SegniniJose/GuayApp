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
	points.text = "%s pts" % str(ranking.points)
	GuayTheme.apply_label(username, GuayTheme.FONT_BODY, GuayTheme.COLOR_TEXT, true)
	GuayTheme.apply_label(points, GuayTheme.FONT_LABEL, GuayTheme.COLOR_PRIMARY, true)
	GuayTheme.apply_label(rank, GuayTheme.FONT_BODY, GuayTheme.COLOR_TEXT_MUTED, true)
	await avatar.set_url(ranking.avatar)
