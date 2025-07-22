extends Node

var overlays = []

func push_overlay(preloaded):
	var overlay = preloaded.instance()
	get_tree().current_scene.add_child(overlay)
	overlays.append(overlay)
	return overlay

func pop_overlay():
	if overlays.size() > 0:
		var overlay = overlays.pop_back()
		overlay.queue_free()
