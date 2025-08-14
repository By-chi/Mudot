extends Control
class_name Element
var class_name_str:="Element"
var can_set_property_names:=Dictionary()
var re_init:=true
func _ready() -> void:
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
	
	
