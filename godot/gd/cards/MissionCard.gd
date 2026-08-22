extends PanelContainer

@onready var label: Label = %Label

var id = ""

const ICONS := {
	"verde": "🌿",
	"perro": "🐶",
	"gato": "🐱",
	"café": "☕",
	"cafe": "☕",
	"amigo": "👫",
	"amanecer": "🌅",
	"atardecer": "🌅",
	"libro": "📖",
	"azul": "💙",
	"paisaje": "🌄",
}


func _ready() -> void:
	var s := GuayTheme.make_flat(GuayTheme.COLOR_SURFACE, 16, 6, GuayTheme.COLOR_BORDER, 1)
	add_theme_stylebox_override("panel", s)


func _icon_for(desc: String) -> String:
	var d := desc.to_lower()
	for k in ICONS.keys():
		if d.find(k) >= 0:
			return ICONS[k]
	return "🎯"


func set_mission(mission: Dictionary):
	var pts := str(mission.points)
	if typeof(mission.points) == TYPE_FLOAT or typeof(mission.points) == TYPE_INT:
		pts = "%.1f" % float(mission.points)
	var status := ""
	if mission.get("isPending", false):
		status = "  ·  ⏳ En validación"
	elif mission.get("completed", false):
		status = "  ·  ✅ Completada"
	var icon := _icon_for(str(mission.get("description", "")))
	label.text = "%s  %s\n%s pts%s" % [icon, mission.description, pts, status]
	GuayTheme.apply_label(label, GuayTheme.FONT_BODY, GuayTheme.COLOR_TEXT)
	# Puntos en azul: segunda línea se ve con color vía modulate del label no es ideal;
	# dejamos tipografía clara como mockup.
	id = str(mission.id)


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
