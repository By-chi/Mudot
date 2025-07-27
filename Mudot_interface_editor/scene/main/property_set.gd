extends Panel
func show_inspectoscope(node:Control)->void:
	for i in $VBoxContainer.get_children():
		if i is Control:
			$VBoxContainer.remove_child(i)
			i.queue_free()
	for i in node.can_set_property_names:
		var type=node.can_set_property_names[i][0]
		var path:String=Global.PROPERTY_SET_DIR_PATH+type+"/"+type+".tscn"
		var property_set_node=load(path).instantiate()
		property_set_node.property_name=i
		property_set_node.host=node
		property_set_node.tool_tip_text=node.can_set_property_names[i][1]
		property_set_node.name=i
		$VBoxContainer.add_child(property_set_node)
func hide_inspectoscope()->void:
	for i in $VBoxContainer.get_children():
		if i is Control:
			i.queue_free()
