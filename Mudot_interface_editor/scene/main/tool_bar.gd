extends HBoxContainer
var current_index:=0:
	set(value):
		current_index=value
		Global.select_control_box(Global.main_node.current_element)
func _input(event: InputEvent) -> void:
	if current_index==0:
		if event is InputEventMouseMotion:
			if Input.is_action_pressed("mouse_left")&&Input.is_action_pressed("space"):
				Global.main_node.main_scene.position+=event.relative
	elif current_index==1:
		if event is InputEventMouseMotion:
			if Input.is_action_pressed("mouse_left"):
				if Global.main_node.current_element.can_set_property_names.has("position"):
					var node=Global.main_node.inspectoscope.get_node_or_null("VBoxContainer/"+"position")
					if node!=null:
						node.value+=event.relative
						node.update()

func _on_select_pressed() -> void:
	current_index=0
func _on_move_pressed() -> void:
	current_index=1
func _on_build_pressed() -> void:
	Global.build_expand_script()
