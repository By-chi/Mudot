extends Window

func _ready() -> void:
	$Panel/VBoxContainer.visible=Global.current_mudot_file_path.is_absolute_path()
	_load_property_set_UI_list()
	$Panel/Mudot/Mudot.text=Global.current_mudot_file_path
	
func _on_close_requested() -> void:
	queue_free()
func _on_mudot_pressed() -> void:
	DisplayServer.file_dialog_show("mudot文件选择",$Panel/Mudot/Mudot.text,"",false,DisplayServer.FILE_DIALOG_MODE_OPEN_FILE,["*.mudot"],set_mudot_path)
@warning_ignore("unused_parameter")
func set_mudot_path(status: bool, selected_path: PackedStringArray, selected_filter_index: int)->void:
	if status:
		Global.save()
		Global.load_scene_from_mudot(selected_path[0])
		queue_free()
func _on_mudot_text_submitted(new_text:  String) -> void:
	Global.save()
	Global.load_scene_from_mudot(new_text)
	queue_free()
func _load_property_set_UI_list()->void:
	if !Global.current_mudot_file_path.is_absolute_path():
		return
	var data=Global.get_data_from_json(Global.current_mudot_file_path)
	for i in property_name_list:
		if data.has(i[0]):
			
			var type_str:String=i[1]
			var node=load("res://scene/main/property_set/"+type_str+"/"+type_str+".tscn").instantiate()
			node.host=self
			node.property_name=i[0]
			node.name=i[0]
			node.tool_tip_text=i[2]
			$Panel/VBoxContainer.add_child(node)
			var value=data[i[0]]
			if i[1] == "Color":
				value = Color(value)
			elif i[1] == "Vector2":
				value=Vector2(value[0],value[1])
			set(i[0],value)
			node.value=value
			node.update()
#region 项目属性
var property_name_list:=[
	["song_name","String","歌曲的名字\n※:这是必要的"],["singer","String","歌手"],["CD_cover_path","String","CD封面图片路径,最好是方形的"],
	["introduction","String","引言"],["introduction_color","Color","引言颜色"],["template_path","String","场景路径\n※:这是必要的"],
	["list_cover_path","String","列表中显示的图片文件路径,最好是横向条形的"],["suggested_window_size","Vector2","播放时推荐窗口大小\n※:此大小并不是此场景显示大小"],
]
func _change_project_property_json(property_name:String,property_value:Variant)->void:
	#print()
	if !Global.current_mudot_file_path.is_absolute_path():
		return
	var data=Global.get_data_from_json(Global.current_mudot_file_path)
	if property_name_list[$Panel/VBoxContainer.get_node(property_name).get_index()][1] == "Color":
		data[property_name]="#"+property_value.to_html()
	elif property_name_list[$Panel/VBoxContainer.get_node(property_name).get_index()][1] == "Vector2":
		data[property_name]=[property_value.x,property_value.y]
	else:
		data[property_name]=property_value
	var file = FileAccess.open(Global.current_mudot_file_path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data, "\t"))
		file.close()
var song_name:String:
	set(value):
		song_name=value
		_change_project_property_json("song_name",value)
var singer:String:
	set(value):
		singer=value
		_change_project_property_json("singer",value)
var CD_cover_path:String:
	set(value):
		CD_cover_path=value
		_change_project_property_json("CD_cover_path",value)
var introduction:String:
	set(value):
		introduction=value
		_change_project_property_json("introduction",value)
		
var introduction_color:Color:
	set(value):
		introduction_color=value
		_change_project_property_json("introduction_color",value)
		
var template_path:String:
	set(value):
		template_path=value
		_change_project_property_json("template_path",value)

var list_cover_path:String:
	set(value):
		list_cover_path=value
		_change_project_property_json("list_cover_path",value)
var suggested_window_size:Vector2:
	set(value):
		suggested_window_size=value
		_change_project_property_json("suggested_window_size",value)


#endregion
