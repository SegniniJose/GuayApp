extends PanelContainer

@onready var you_tag: PanelContainer = %YouTag
@onready var rank: Label = %RankLabel
@onready var avatar: TextureRectUrl = %Avatar
@onready var username: Label = %UsernameLabel
@onready var level_label: Label = %LevelLabel
@onready var trend_label: Label = %TrendLabel
@onready var points: Label = %PointsLabel
@onready var progress_bar: ProgressBar = %ProgressBar


func set_ranking(rank_number: int, ranking: Dictionary):
	if you_tag:
		you_tag.visible = false

	var is_current_user := (ranking.get("id", "") == Globals.user_id)
	var pts: int = ranking.get("points", 0)
	var lvl: int = max(1, int(pts / 100) + 1)

	rank.text = str(rank_number)
	username.text = "Tú" if is_current_user else ranking.get("username", "Jugador")
	level_label.text = "Nivel %d" % lvl
	points.text = "%d pts" % pts

	var pct := int(pts % 100)
	if progress_bar:
		progress_bar.value = pct

	# Trend
	if trend_label:
		if rank_number % 2 == 0:
			trend_label.text = "↑1"
			trend_label.add_theme_color_override("font_color", GuayTheme.COLOR_SUCCESS)
		else:
			trend_label.text = "↓1"
			trend_label.add_theme_color_override("font_color", GuayTheme.COLOR_DANGER)

	# Highlight current user card
	if is_current_user:
		var highlight := StyleBoxFlat.new()
		highlight.bg_color = Color("eff6ff")
		highlight.set_corner_radius_all(16)
		highlight.border_color = Color("93c5fd")
		highlight.set_border_width_all(1)
		highlight.shadow_color = Color(0, 0.4, 1.0, 0.1)
		highlight.shadow_size = 6
		add_theme_stylebox_override("panel", highlight)
		username.add_theme_color_override("font_color", GuayTheme.COLOR_PRIMARY)
		points.add_theme_color_override("font_color", GuayTheme.COLOR_PRIMARY)
		rank.add_theme_color_override("font_color", GuayTheme.COLOR_PRIMARY)

	await avatar.set_url(ranking.get("avatar", ""))
