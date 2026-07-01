extends PanelContainer

@onready var label: Label = %Label

var id = ""


func set_mission(mission: Dictionary):
	print("set_mission ", mission)
	label.text = "📸 " + mission.description + "\n(" + str(mission.points) + " pts)"
	if mission.isPending:
		label.text += " En validación..."
	id = mission.id


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			Globals.current_mission_id = id
			get_tree().change_scene_to_file("res://tscn/CompleteMission.tscn")
