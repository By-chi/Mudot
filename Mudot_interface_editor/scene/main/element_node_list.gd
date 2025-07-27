extends Panel
func add_element(node:Control)->void:
	var element_ui_node=preload("res://scene/main/element_list_element_ui.tscn").instantiate()
	element_ui_node.host=node
	$VBoxContainer.add_child(element_ui_node)
func free_element(node:Control)->void:
	$VBoxContainer.get_child(node.get_index()).queue_free()
func clear_elements()->void:
	for i in $VBoxContainer.get_children():
		i.queue_free()
