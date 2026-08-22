extends PanelContainer

@onready var label: Label = %Label

var id = ""


func _ready() -> void:
	GuayTheme.apply_panel(self, GuayTheme.panel_surface())


func set_mission(mission: Dictionary):
	print("set_mission ", mission)
	var pts = str(mission.points)
	if typeof(mission.points) == TYPE_FLOAT or typeof(mission.points) == TYPE_INT:
		pts = "%.1f" % float(mission.points)
	var status := ""
	if mission.get("isPending", false):
		status = "  ·  En validación..."
	elif mission.get("completed", false):
		status = "  ·  Completada"
	label.text = "%s\n%s pts%s" % [mission.description, pts, status]
	GuayTheme.apply_label(label, GuayTheme.FONT_BODY, GuayTheme.COLOR_TEXT)
	id = mission.id


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			if typeof(Globals.missions) == TYPE_ARRAY:
				for m in Globals.missions:
					if str(m.get("id", "")) == str(id) and m.get("completed", false):
						Globals.show_popup(self, "Misión", "Ya completaste esta misión.")
						return
			Globals.current_mission_id = id
			get_tree().change_scene_to_file("res://tscn/CameraCapture.tscn")
