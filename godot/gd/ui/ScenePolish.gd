extends Node

const APP_MAX_WIDTH: float = 460.0


func _ready() -> void:
	get_tree().root.child_entered_tree.connect(_on_child_entered)
	get_tree().root.size_changed.connect(_on_window_resized)
	call_deferred("_polish_scene")


func _on_child_entered(node: Node) -> void:
	if node == get_tree().current_scene:
		call_deferred("_polish_scene")


func _on_window_resized() -> void:
	call_deferred("_polish_scene")


func _polish_scene() -> void:
	var root := get_tree().current_scene
	if root == null or not (root is Control):
		return

	GuayTheme.fade_in(root)

	var vp := root.get_viewport()
	if vp == null:
		return
	var win_w: float = vp.get_visible_rect().size.x
	var is_desktop: bool = win_w > 520.0

	_apply_container_sizing(root, is_desktop, win_w)
	_sanitize_broken_glyphs(root)


func _apply_container_sizing(node: Node, is_desktop: bool, win_w: float) -> void:
	if node == null:
		return

	if node is PanelContainer and (node.is_in_group("background_panel") or node.name == "BackgroundPanel"):
		if is_desktop:
			node.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
			node.custom_minimum_size.x = APP_MAX_WIDTH
		else:
			node.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			node.custom_minimum_size.x = 0

	for child in node.get_children():
		if child is Control:
			_apply_container_sizing(child, is_desktop, win_w)


func _sanitize_broken_glyphs(node: Node) -> void:
	if node == null:
		return

	if node is Label:
		var txt: String = node.text
		if "→" in txt or "↑" in txt or "↓" in txt or "📸" in txt or "👥" in txt or "🎯" in txt or "🏆" in txt or "📅" in txt or "🔒" in txt:
			txt = txt.replace("→", ">")
			txt = txt.replace("↑", "+")
			txt = txt.replace("↓", "-")
			txt = txt.replace("📸", "")
			txt = txt.replace("👥", "")
			txt = txt.replace("🎯", "")
			txt = txt.replace("🏆", "")
			txt = txt.replace("📅", "")
			txt = txt.replace("🔒", "")
			node.text = txt
	elif node is Button:
		var txt: String = node.text
		if "→" in txt or "↑" in txt or "↓" in txt:
			node.text = txt.replace("→", ">").replace("↑", "+").replace("↓", "-")
	elif node is RichTextLabel:
		var txt: String = node.text
		if "→" in txt or "↑" in txt or "↓" in txt:
			node.text = txt.replace("→", ">").replace("↑", "+").replace("↓", "-")

	for child in node.get_children():
		_sanitize_broken_glyphs(child)
