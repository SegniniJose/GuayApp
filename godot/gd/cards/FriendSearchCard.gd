extends PanelContainer

@onready var user_name = %Username
@onready var user_id = %UserId
@onready var avatar = %Avatar


func _on_add_button_pressed() -> void:
	var callback = func(response: Dictionary):
		print("Add Friends Success!", response)
		get_tree().change_scene_to_file("res://tscn/Friends.tscn")
	var url = Globals.get_api_friends_request_url()
	var friendId = user_id.text
	var data = {
		"userId": Globals.user_id,
		"friendId": friendId,
	}
	var request_body = JSON.stringify(data)
	print("_on_add_button_pressed ", url, " ", request_body)
	Globals.http_post_callback(self, url, data, callback)
