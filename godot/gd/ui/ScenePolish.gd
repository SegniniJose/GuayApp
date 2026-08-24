extends Node


func _ready() -> void:
	get_tree().root.child_entered_tree.connect(_on_child_entered)
	call_deferred("_fade_current")


func _on_child_entered(node: Node) -> void:
	if node == get_tree().current_scene and node is CanvasItem:
		call_deferred("_fade_current")


func _fade_current() -> void:
	var root := get_tree().current_scene
	if root is CanvasItem:
		GuayTheme.fade_in(root)
