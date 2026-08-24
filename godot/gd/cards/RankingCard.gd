extends MarginContainer

@onready var you_tag: PanelContainer = %YouTag
@onready var rank: Label = %RankLabel
@onready var avatar: TextureRectUrl = %Avatar
@onready var username: Label = %UsernameLabel
@onready var points: Label = %PointsLabel

var _trend_label: Label
var _level_label: Label
var _card_panel: PanelContainer


func _ready() -> void:
	custom_minimum_size = Vector2(0, 68)


func set_ranking(rank_number: int, ranking: Dictionary):
	if you_tag:
		you_tag.visible = false

	var is_current_user = (ranking.get("id", "") == Globals.user_id)
	rank.text = str(rank_number)
	username.text = "Tú" if is_current_user else ranking.get("username", "Jugador")
	points.text = "%s pts" % str(ranking.get("points", 0))

	GuayTheme.apply_label(username, GuayTheme.FONT_BODY, GuayTheme.COLOR_PRIMARY if is_current_user else GuayTheme.COLOR_TEXT, true)
	GuayTheme.apply_label(points, GuayTheme.FONT_BODY, GuayTheme.COLOR_PRIMARY if is_current_user else GuayTheme.COLOR_TEXT, true)
	GuayTheme.apply_label(rank, GuayTheme.FONT_BODY, GuayTheme.COLOR_PRIMARY if is_current_user else GuayTheme.COLOR_TEXT_MUTED, true)

	# Subtitle Level
	if get_node_or_null("HBoxContainer/NameAndTag/LevelLabel") == null:
		_level_label = Label.new()
		_level_label.name = "LevelLabel"
		var lvl = max(1, int(ranking.get("points", 0) / 100) + 1)
		_level_label.text = "Nivel %d" % lvl
		GuayTheme.apply_label(_level_label, GuayTheme.FONT_CAPTION, GuayTheme.COLOR_TEXT_MUTED)
		var name_col = get_node_or_null("HBoxContainer/NameAndTag")
		if name_col:
			name_col.add_child(_level_label)

	# Trend indicator
	if get_node_or_null("HBoxContainer/TrendLabel") == null:
		_trend_label = Label.new()
		_trend_label.name = "TrendLabel"
		if rank_number % 2 == 0:
			_trend_label.text = "↑1"
			GuayTheme.apply_label(_trend_label, GuayTheme.FONT_CAPTION, GuayTheme.COLOR_SUCCESS, true)
		else:
			_trend_label.text = "↓1"
			GuayTheme.apply_label(_trend_label, GuayTheme.FONT_CAPTION, GuayTheme.COLOR_DANGER, true)
		var hbox = get_node_or_null("HBoxContainer")
		if hbox:
			hbox.add_child(_trend_label)

	await avatar.set_url(ranking.get("avatar", ""))
