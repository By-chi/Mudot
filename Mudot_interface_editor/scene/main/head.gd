extends Panel
func _on_project_pressed() -> void:
	var window:=preload("res://scene/main/project_window.tscn").instantiate()
	add_child(window)
