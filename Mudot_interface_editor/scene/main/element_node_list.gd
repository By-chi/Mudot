extends VBoxContainer
func add_element(node:Control)->void:
	var element_ui_node=preload("res://scene/main/element_list_element_ui.tscn").instantiate()
	element_ui_node.host=node
	add_child(element_ui_node)
func free_element(node:Control)->void:
	get_child(node.get_index()).queue_free()
func clear_elements()->void:
	for i in get_children():
		i.queue_free()
