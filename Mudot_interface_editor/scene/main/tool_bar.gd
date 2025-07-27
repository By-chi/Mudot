extends HBoxContainer
var current_index:=0
func _input(event: InputEvent) -> void:
	if !Global.mouse_is_in_main_scene():
		return
	if current_index==0:
		pass
	elif current_index==1:
		if event is InputEventMouseMotion:
			if Input.is_action_pressed("mouse_left"):
				#if Global.main_node.current_element.can_set_property_names.has("Position"):
				if Global.main_node.current_element.can_set_property_names.has("position"):
					#var node=Global.main_node.inspectoscope.get_node("VBoxContainer/"+"Position")
					var node=Global.main_node.inspectoscope.get_node_or_null("VBoxContainer/"+"position")
					#if node.get_method_list:
					if node!=null:
						node.value+=event.relative
						node.update()

func _on_select_pressed() -> void:
	current_index=0
func _on_move_pressed() -> void:
	current_index=1
