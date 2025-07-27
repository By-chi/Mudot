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
			if can_set_property_names[i[0]][0]=="Array":
				call("set_"+i[0],i[1])
			else:
				set(i[0],i[1])
	if Global.in_editor:
		Global.main_node.current_element=self
		Global.main_node.element_node_list.add_element(self)
func quit()->void:
	queue_free()
	if Global.in_editor:
		Global.main_node.element_node_list.free_element(self)
		Global.main_node.current_element=null
