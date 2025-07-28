extends CanvasLayer
var main_node:Control
var in_editor:=true
var current_mudot_file_path:String:
	set(value):
		if value.is_absolute_path():
			current_mudot_file_path=value
			set_configfile("file_path_memory","last_mudot_file_path",value)
	get():
		if !current_mudot_file_path.is_absolute_path():
			current_mudot_file_path=Global.get_configfile("file_path_memory","last_mudot_file_path","")
		return current_mudot_file_path

#region tip
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

#region const
const CONFIG_FILE_PATH:="user://config.cfg"
const ELEMENTS_DIR_PATH:="res://scene/elements/"
const PROPERTY_SET_DIR_PATH:="res://scene/main/property_set/"
#endregion

#region save
func get_data_from_json(path:String)->Variant:
	var file=FileAccess.open(path,FileAccess.READ)
	if file==null:
		return null
	var data = JSON.parse_string(file.get_as_text())
	file.close()
	return data
func load_scene_from_mudot(path:String)->void:
	var data = get_data_from_json(path)
	if data==null:
		return
	var node=main_node.main_scene.get_parent()
	current_mudot_file_path=path
	main_node.main_scene.queue_free()
	main_node.inspectoscope.hide_inspectoscope()
	main_node.element_node_list.clear_elements()
	var template_path = path.get_base_dir()+"/"+data["template_path"]
	print(template_path)
	var scene=load(template_path).instantiate()
	for i in scene.get_children():
		i.re_init=false
	node.add_child(scene)
	main_node.main_scene=scene
	# 加载变量数据 - 与场景文件同目录，传入scene作为参考节点
	var variables_path = template_path.get_basename() + "_variables.json"
	load_script_variables_from_json(scene, variables_path, scene)  # 增加参考节点参数
	


# 从JSON加载节点脚本变量，增加reference_node参数
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
		restore_script_variables(node, variables_data, reference_node)  # 增加参考节点参数
# 递归恢复节点的脚本变量，增加reference_node参数
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
func load_image_from_absolute_path(path: String) -> Texture2D:
	if path==""||path.ends_with("/"):
		return null
	var image = Image.new()
	var err = image.load(path)
	if err != OK:
		return null
	var texture = ImageTexture.create_from_image(image)
	return texture


# 保存节点脚本变量到JSON，增加reference_node参数
func save_script_variables_to_json(node: Node, json_path: String, reference_node: Node) -> void:
	var variables_data = {}
	collect_script_variables(node, variables_data, reference_node)  # 增加参考节点参数
	var file = FileAccess.open(json_path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(variables_data, "\t"))
		file.close()
		print("变量已保存到: ", json_path)
	else:
		print("无法保存变量文件: ", json_path)

# 递归收集节点的脚本变量，增加reference_node参数
func collect_script_variables(node: Node, data: Dictionary, reference_node: Node) -> void:
	if node.get_script() != null:
		var rel_path = reference_node.get_path_to(node)
		var node_data = {}  # 临时存储当前节点的变量数据
		var has_can_set_property_names := false
		
		for i in node.get_property_list():
			if i["name"] == "can_set_property_names":
				has_can_set_property_names = true
		
		if has_can_set_property_names:
			for var_name in node.can_set_property_names.keys():
				if node.can_set_property_names[var_name][0] == "Color":
					node_data[var_name] = [node.get(var_name).r, node.get(var_name).g, node.get(var_name).b, node.get(var_name).a]
				elif node.can_set_property_names[var_name][0] == "Vector2":
					node_data[var_name] = [node.get(var_name).x, node.get(var_name).y]
				else:
					node_data[var_name] = node.get(var_name)
		if node_data!=Dictionary():
			data[rel_path] = node_data
	for child in node.get_children():
		collect_script_variables(child, data, reference_node)  # 传递参考节点

func get_children_deep(node: Node,call_func:Callable,include_internal:=true) -> void:
	var call_earliest:=call_func
	for child in node.get_children(include_internal):
		call_func.bind(child).call()
		get_children_deep(child,call_earliest,include_internal)
		
func _set_owner(node:Node,owner_node:Node)->void:
	node.scene_file_path=""
	node.owner=owner_node
var is_quiting:=false
func quit()->void:
	if is_quiting:
		return
	is_quiting=true
	main_node.inspectoscope.hide_inspectoscope()
	var pack=PackedScene.new()
	for i in main_node.main_scene.get_children():
		i.owner=main_node.main_scene
	get_children_deep(main_node.main_scene,_set_owner.bind(main_node.main_scene))
	pack.pack(main_node.main_scene)
	var base_dir = current_mudot_file_path.get_base_dir()
	var template_path = get_data_from_json(current_mudot_file_path)["template_path"]
	var scene_path = base_dir + "/" + template_path
	var variables_path = scene_path.get_basename() + "_variables.json"
	ResourceSaver.save(pack, scene_path)
	save_script_variables_to_json(main_node.main_scene, variables_path, main_node.main_scene)  # 增加参考节点参数
#endregion
#region 自带函数
func _ready() -> void:
	get_window().connect("close_requested",quit)
func _physics_process(delta: float) -> void:
	if Engine.get_physics_frames()%10==0:
		if $Outline.visible&&current_show_select_control!=null:
			select_control_box(current_show_select_control)
#endregion

#region other functions
var select_control_box_visibility_region:Rect2
var current_show_select_control:Control
func _set_select_control_box_visibility_region(node:Node)->void:
	if node is Control:
		select_control_box_visibility_region=select_control_box_visibility_region.merge(node.get_global_rect())
func select_control_box(node:Control)->void:
	current_show_select_control=node
	$Outline.show()
	select_control_box_visibility_region=node.get_global_rect()
	get_children_deep(node,_set_select_control_box_visibility_region)
	select_control_box_visibility_region=select_control_box_visibility_region.intersection(main_node.main_scene.get_global_rect())
	$Outline.size=select_control_box_visibility_region.size+Vector2(8,8)
	$Outline.position=select_control_box_visibility_region.position-Vector2(4,4)
func hide_select_box()->void:
	$Outline.hide()
func mouse_is_in_main_scene()->bool:
	return Rect2(main_node.main_scene.global_position,main_node.main_scene.size).has_point(get_viewport().get_mouse_position())
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
