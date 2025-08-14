extends VBoxContainer
func add_element(node:Control)->void:
	
	Global.unredo.create_action("action")
	var element_ui_node=preload("res://scene/main/element_list_element_ui.tscn").instantiate()
	Global.unredo.add_do_method(
		func():
			var _element_ui_node:=element_ui_node.duplicate()
			_element_ui_node.host=node
			if !node.is_inside_tree():
				Global.main_node.main_scene.add_child(node)
			add_child(_element_ui_node)
	)
	Global.unredo.add_undo_method(
		func():
			if node.is_inside_tree():
				Global.main_node.main_scene.remove_child(node)
			free_element(element_ui_node)
	)
	Global.unredo.commit_action()
	
func free_element(node:Control)->void:
	get_child(node.get_index()).queue_free()
func clear_elements()->void:
	for i in get_children():
		i.queue_free()
