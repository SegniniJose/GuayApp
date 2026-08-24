extends PanelContainer
class_name MissionCard

@onready var title_label: Label = %TitleLabel
@onready var pts_label: Label = %PtsLabel
@onready var icon_label: Label = %IconLabel

var mission_id: String = ""


func set_mission(mission: Dictionary) -> void:
	mission_id = str(mission.get("id", ""))
	var desc: String = mission.get("description", mission.get("title", "Misión"))
	title_label.text = desc
	var p: float = float(mission.get("points", 10))
	pts_label.text = "%.1f pts" % p


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		Globals.current_mission_id = mission_id
		get_tree().change_scene_to_file("res://tscn/CameraCapture.tscn")
