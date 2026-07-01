extends Control

@onready var avatar: TextureRectUrl = %Avatar
@onready var friend_name: RichTextLabel = %FriendName
@onready var task_description: RichTextLabel = %TaskDescription
@onready var center_container: CenterContainer = %CenterContainer
@onready var placeholder_content: VBoxContainer = %PlaceholderContent
@onready var already_voted: PanelContainer = %AlreadyVoted
@onready var vote_true_false: PanelContainer = %VoteTrueFalse
@onready var already_voted_label: Label = %AlreadyVotedLabel

var vote: String = ""
var preview_rect: TextureRect = null


func _ready() -> void:
	await get_stories()


func refresh_stories() -> void:
	print("Globals.stories ", Globals.stories)
	for user_and_stories in Globals.stories:
		for story in user_and_stories.stories:
			if story.missionCompletionId == Globals.mission_completion_id:
				show_user_story(user_and_stories)
				show_story(story)
	refresh_votes()

func show_user_story(user_and_stories: Dictionary) -> void:
	print("show_user_story ", user_and_stories)
	friend_name.text = user_and_stories.username
	await avatar.set_url(user_and_stories.avatar)

func show_story(story: Dictionary) -> void:
	print("show_story ", story)
	if story.myVote == null:
		vote = ""
		already_voted_label.text = "Ya votaste: 🤔"
	else:
		if story.myVote:
			vote = "verdadera"
			already_voted_label.text = "Ya votaste: ✅ verdadera"
		else:
			vote = "falsa"
			already_voted_label.text = "Ya votaste: ❌ falsa"
	print("show_story vote ", vote)
	task_description.text = story.missionDescription
	
	var photoUrl = story.photoUrl
	var photo: Image = SvgTranscoder.svg_base64_to_image(photoUrl)
	var texture := ImageTexture.create_from_image(photo)
	placeholder_content.visible = false

	if preview_rect and is_instance_valid(preview_rect):
		preview_rect.queue_free()

	preview_rect = TextureRect.new()
	preview_rect.texture = texture
	preview_rect.expand_mode = TextureRect.EXPAND_KEEP_SIZE
	preview_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED

	preview_rect.custom_minimum_size = Vector2(0, 180)

	center_container.add_child(preview_rect)


func get_stories() -> void:
	var callback = func(response: Array):
		print("Get Stories Success!", response)
		Globals.stories.clear()
		Globals.stories.assign(response)
		refresh_stories()
	var url = Globals.get_api_stories_url()
	await Globals.http_request_callback(self, url, callback)


func refresh_votes() -> void:
	if vote == "":
		already_voted.visible = false
		vote_true_false.visible = true
	else:
		already_voted.visible = true
		vote_true_false.visible = false


func _on_falsa_button_pressed() -> void:
	vote = "falsa"
	await post_vote()


func _on_verdadera_button_pressed() -> void:
	vote = "verdadera"
	await post_vote()


func get_vote_bool() -> String:
	match vote:
		"falsa":
			return "false"
		"verdadera":
			return "true"
		_:
			return ""


func post_vote() -> void:
	var callback = func(response: Dictionary):
		print("Post Vote Success!", response)
		Globals.votes.clear()
		Globals.votes.assign(response)
		await get_stories()
	var url = Globals.get_api_votes_url()
	var data = {
		"isValid": get_vote_bool(),
		"missionCompletionId": Globals.mission_completion_id,
		"userId": Globals.user_id,
	}
	print("post_vote ", url, " ", data)
	await Globals.http_post_callback(self, url, data, callback)
