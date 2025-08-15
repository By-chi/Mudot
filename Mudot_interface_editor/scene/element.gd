extends Control
class_name Element
var class_name_str:="Element"
var can_set_property_names:=Dictionary()
var re_init:=true
func array_to_markdown_table(data_array: Array) -> String:
	# 检查输入是否为空
	if data_array==[]:
		return ""
	
	# 构建表格头部
	var table = "|名称|类型|描述|特殊默认值|\n"
	table += "|-----|-----|-----|-----------------------|\n"
	
	# 遍历数组添加表格内容行
	for row in data_array:
		# 确保每行有4个元素，不足则用空字符串补充
		while row.size() < 4:
			row.append("")
		
		# 处理默认值为空的情况
		var default_value = row[3] if row[3] != null else ""
		
		# 添加一行数据
		table += "|%s|%s|%s|%s|\n" % [
			row[0],  # 名称
			row[1],  # 类型
			row[2],  # 描述
			default_value  # 默认值
		]
	
	return table
func _ready() -> void:
	var arr:Array[Array]
	var arr_2:Array
	for i in can_set_property_names:
		arr_2.clear()
		arr_2.append(i)
		arr_2.append(can_set_property_names[i][0])
		arr_2.append(can_set_property_names[i][1])
		if can_set_property_names[i].size()==3:
			arr_2.append(can_set_property_names[i][2])
		arr.append(arr_2.duplicate_deep())
	print(array_to_markdown_table(arr))
	if !Global.in_editor:
		re_init=false
	if re_init:
		name=class_name_str+str(randi())
		for i in Global.get_type_default_from_set_property_names(can_set_property_names):
			set(i[0],i[1])
	if Global.in_editor:
		Global.main_node.current_element=self
		Global.main_node.element_node_list.add_element(self)
func quit()->void:
	if Global.in_editor:
		Global.unredo.create_action("action")
		Global.unredo.add_do_method(
			func():
				hide()
				set_process(false)
				set_physics_process(false)
				Global.main_node.main_scene.remove_child(self)
				Global.main_node.element_node_list.free_element(self)
				Global.main_node.current_element=null
		)
		Global.unredo.add_undo_method(
			func():
				show()
				set_process(true)
				set_physics_process(true)
				Global.main_node.main_scene.add_child(self)
				Global.main_node.element_node_list.add_element(self)
				Global.main_node.current_element=self
		)
		Global.unredo.commit_action()
	else:
		queue_free()
	
	
