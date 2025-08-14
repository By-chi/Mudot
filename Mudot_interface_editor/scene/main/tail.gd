extends Panel
@export var progress_bar:ProgressBar

func _on_save_pressed() -> void:
	Global.save()



func _on_undo_pressed() -> void:
	if Global.unredo.has_undo():
		Global.unredo.undo()



func _on_redo_pressed() -> void:
	if Global.unredo.has_redo():
		Global.unredo.redo()

func set_progress(value:float,is_end:=false)->void:
	
	progress_bar.value=value
	progress_bar.visible=!is_end
	progress_bar.queue_redraw()
	
	
