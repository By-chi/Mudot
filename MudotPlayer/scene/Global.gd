extends Node
#region 对接编辑器的内容
var in_editor:=false
var current_mudot_file_path:String
func load_script_variables_from_json(node: Node, json_path: String, reference_node: Node) -> void:
	if !FileAccess.file_exists(json_path):
		print("变量文件不存在: ", json_path)
		return
	var file = FileAccess.open(json_path, FileAccess.READ)
	if !file:
		print("无法打开变量文件: ", json_path)
		return
	var variables_data = JSON.parse_string(file.get_as_text())
	file.close()
	if variables_data:
		restore_script_variables(node, variables_data, reference_node)
func restore_script_variables(node: Node, data: Dictionary, reference_node: Node) -> void:
	var rel_path = str(reference_node.get_path_to(node))
	if data.has(rel_path):
		
		var node_data = data[rel_path]
		var has_can_set_property_names:=false
		for  i in node.get_property_list():
			if i["name"]=="can_set_property_names":
				has_can_set_property_names=true
		if has_can_set_property_names:
			for var_name in node.can_set_property_names.keys():
				var value=node_data[var_name]
				if node.can_set_property_names[var_name][0] == "Color":
					if typeof(value) == TYPE_STRING:
						value = Color(value)
					elif typeof(value) == TYPE_ARRAY:
						value = Color(value[0], value[1], value[2], value[3] if value.size() > 3 else 1.0)
					
				elif node.can_set_property_names[var_name][0] == "Vector2":
					value=Vector2(value[0],value[1])
				node.set(var_name, value)
	# 递归处理子节点
	for child in node.get_children():
		restore_script_variables(child, data, reference_node)  # 传递参考节点
func get_type_default_from_string(type_str:String)->Variant:
	if type_str=="String":
		return String()
	elif type_str=="int":
		return int()
	elif type_str=="float":
		return float()
	elif type_str=="Color":
		return Color()
	elif type_str=="Vector2":
		return Vector2()
	elif type_str=="bool":
		return bool()
	return null
func get_type_default_from_set_property_names(set_property_names:Dictionary)->Array:
	var arr:Array
	for i in set_property_names:
		if set_property_names[i].size()==3:
			arr.append([i,set_property_names[i][2]])
		else:
			var type=set_property_names[i][0]
			arr.append([i,get_type_default_from_string(type)])
	return arr
#endregion

#region save
func get_data_from_json(path:String)->Variant:
	var file=FileAccess.open(path,FileAccess.READ)
	if file==null:
		return null
	var data = JSON.parse_string(file.get_as_text())
	file.close()
	return data
var user_leven:
	set(value):
		user_leven=value
		set_configfile("user","user_leven",user_leven)
const CONFIG_FILE_PATH:="user://config.cfg"
func set_configfile(section: String, key: String, value: Variant)->void:
	create_if_missing(CONFIG_FILE_PATH)
	var cfg:=ConfigFile.new()
	cfg.load(CONFIG_FILE_PATH)
	cfg.set_value(section,key,value)
	cfg.save(CONFIG_FILE_PATH)
func get_configfile(section: String, key: String,default: Variant = null)->Variant:
	create_if_missing(CONFIG_FILE_PATH)
	var cfg:=ConfigFile.new()
	cfg.load(CONFIG_FILE_PATH)
	return cfg.get_value(section,key,default)

func close_window()->void:
	set_configfile("window_memory","window_position",get_window().position)
	set_configfile("window_memory","window_size",get_window().size)
	get_node("/root/Panel/AnimationPlayer").play_backwards("start")
	get_node("/root/Panel/AnimationPlayer").connect("animation_finished",get_tree().quit)
static func create_if_missing(path:String)->void:
	var exists = DirAccess.dir_exists_absolute(path) || FileAccess.file_exists(path)
	if exists:
		return
	if path.ends_with("/"):
		DirAccess.make_dir_recursive_absolute(path)
	else:
		if !DirAccess.dir_exists_absolute(path.get_base_dir()):
			DirAccess.make_dir_recursive_absolute(path.get_base_dir())
		var file=FileAccess.open(path,FileAccess.WRITE)
		FileAccess.get_open_error()
		file.close()
#endregion



#region pop
func pop(title:String,text:String)->void:
	$ColorRect/Pop/AnimationPlayer.play("show")
	$ColorRect/Pop/Title.text=title
	$ColorRect/Pop/Text.text=text

func _on_button_pressed() -> void:
	$ColorRect/Pop/AnimationPlayer.play_backwards("show")
func show_hint(text:String)->void:
	$Hint/Label.text=text
	$Hint/AnimationPlayer.play("show")
	$Hint/Timer.start(2.0)
	$Hint.size.x=$Hint/Label.text.length()*25+20
	$Hint.pivot_offset=$Hint.size/2
func _on_timer_timeout() -> void:
	$Hint/AnimationPlayer.play_backwards("show")

func show_tooltips(text:String)->void:
	$ToolTips/Timer.start()
	$ToolTips/Timer.connect("timeout",_on_tooltips_timer_timeout.bind(text),CONNECT_ONE_SHOT)
func hide_tooltips()->void:
	if $ToolTips/Timer.is_stopped():
		$ToolTips/AnimationPlayer.play_backwards("show")
	else:
		$ToolTips/Timer.stop()
		$ToolTips/Timer.disconnect("timeout",_on_tooltips_timer_timeout)
func _on_tooltips_timer_timeout(text:String) -> void:
	$ToolTips/AnimationPlayer.play("show")
	$ToolTips/Label.text=text
	var texts:=text.rsplit("\n")
	var l:=0
	for i in texts:
		l=max(l,i.length())
	$ToolTips.size.x=20+l*21
	$ToolTips.size.y=20+texts.size()*23
	$ToolTips.global_position.x=max(min(get_viewport().get_mouse_position().x,get_window().size.x-$ToolTips.size.x-10),10)
	$ToolTips.global_position.y=max(min(get_viewport().get_mouse_position().y-53,get_window().size.y-$ToolTips.size.y-10),0)
#endregion
#region file_load
func load_image_from_absolute_path(path: String) -> Texture2D:
	if path.ends_with("/"):
		return Texture2D.new()
	var image = Image.new()
	var err = image.load(path)
	if err != OK:
		return null
	var texture = ImageTexture.create_from_image(image)
	return texture
#endregion
func _ready() -> void:
	get_window().connect("close_requested",close_window)
func _process(delta: float) -> void:
	if target_size!=Vector2i.ZERO:
		get_window().size=get_window().size*0.7+target_size*0.3
		get_window().position=start_window_central_position-get_window().size/2
	if (get_window().size-target_size).length_squared()<=5:
		get_window().size=target_size
		target_size=Vector2i.ZERO
#region 其他功能
var target_size:=Vector2i.ZERO
var start_window_central_position
func resize_window(size:Vector2i)->void:
	if size<get_window().min_size:
		return
	target_size=size
	start_window_central_position=get_window().position+get_window().size/2
#endregion
