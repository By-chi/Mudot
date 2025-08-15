extends Window
func _on_close_requested() -> void:
	if !$Panel/No.disabled:
		queue_free()
	else:
		get_tree().quit()
var dir:=""
func _on_open_pressed() -> void:
	DisplayServer.file_dialog_show("mudot项目目录选择",
	$Panel/VBoxContainer/Mudot/Mudot.text,"",false,
	DisplayServer.FILE_DIALOG_MODE_OPEN_DIR,
	PackedStringArray(),set_mudot_path)
func set_mudot_path(status: bool, selected_path: PackedStringArray, selected_filter_index: int)->void:
	if status&&selected_path[0]!=""&&DirAccess.dir_exists_absolute(selected_path[0]):
		$Panel/VBoxContainer/Mudot.self_modulate=Color.GREEN
		dir=selected_path[0]
		$Panel/VBoxContainer/Mudot/Mudot.text=dir
	else:
		dir=""
		$Panel/VBoxContainer/Mudot.self_modulate=Color.RED
		
func _on_mudot_text_submitted(new_text:  String) -> void:
	set_mudot_path(true,[new_text],0)

var path:=""
var file_name:=""
func _on_name_text_submitted(new_text:  String) -> void:
	path=dir+"/"+new_text+".mudot"
	file_name=new_text
	if !FileAccess.file_exists(path)&&path.is_absolute_path()&&dir!=""&&new_text!="":
		$Panel/VBoxContainer/Name.self_modulate=Color.GREEN
		$Panel/Yes.disabled=false
	else:
		$Panel/VBoxContainer/Name.self_modulate=Color.RED
		$Panel/Yes.disabled=true


func _on_yes_pressed() -> void:
	if $Panel/Yes.disabled:
		return
	Global.create_if_missing(path)
	Global.create_if_missing(dir+"/"+file_name+".tscn")
	var file=FileAccess.open(path,FileAccess.WRITE)
	if file!=null:
		file.store_string("
{
	\"expand_script_dir_path\": \"expand_script_dir\",
	\"template_path\": \"{0}.tscn\"
}
".format([file_name]))
	file.close()
	print(dir+"/"+file_name+".tscn")
	file=FileAccess.open(dir+"/"+file_name+".tscn",FileAccess.WRITE)
	if file!=null:
		file.store_string("
[gd_scene format=3]
[node name=\"{0}\" type=\"Control\"]
z_index = 1
layout_mode = 1
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
grow_horizontal = 2
grow_vertical = 2
".format([file_name]))
	file.close()
	Global.save()
	Global.load_scene_from_mudot(path)
	queue_free()
