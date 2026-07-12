extends Node


func _ready() -> void:
	get_tree().scene_changed.connect(_on_scene_changed)
	call_deferred("_fade_current")


func _on_scene_changed() -> void:
	call_deferred("_fade_current")


func _fade_current() -> void:
	var root := get_tree().current_scene
	if root is CanvasItem:
		GuayTheme.fade_in(root)
