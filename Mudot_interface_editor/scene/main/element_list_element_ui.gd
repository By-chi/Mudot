extends Panel
var host:Control
var is_doubel_ing:=false

func _on_button_pressed() -> void:
	if is_doubel_ing:
		$Button.mouse_filter=MOUSE_FILTER_IGNORE
		$LineEdit.show()
		is_doubel_ing=false
	Global.main_node.inspectoscope.show_inspectoscope(host)
	$Doubel.start()
	is_doubel_ing=true
func _ready() -> void:
	$Label.text=host.name
	$LineEdit.text=host.name

func _on_doubel_timeout() -> void:
	is_doubel_ing=false


func _on_line_edit_text_submitted(new_text:  String) -> void:
	if new_text.is_valid_filename():
		$Label.text=new_text
		host.name=new_text
		$LineEdit.hide()
		$Button.mouse_filter=MOUSE_FILTER_STOP
func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if Input.is_action_just_released("mouse_right"):
			$Menu.visible=!$Menu.visible


func _on_remove_pressed() -> void:
	host.quit()


func _on_copy_paste_pressed() -> void:
	var new_node = host.duplicate()
	new_node.position=host.position
	if host.script != null:
		var source_vars = host.get_script().get_script_property_list()
		for var_info in source_vars:
			var var_name:String= var_info.name
			if var_name=="re_init":
				new_node.set("re_init",false)
				continue
			if var_name.is_valid_identifier():
				new_node.set(var_name, host.get(var_name))
	host.get_parent().add_child(new_node)


func _on_move_pressed() -> void:
	if $Menu/HBoxContainer/Move.self_modulate.a==0:
		$Menu/HBoxContainer/Move.self_modulate.a=1
		$Menu/HBoxContainer/Move/SpinBox.visible=false
	else:
		$Menu/HBoxContainer/Move.self_modulate.a=0
		$Menu/HBoxContainer/Move/SpinBox.visible=true
	$Menu/HBoxContainer/Move/SpinBox.value=get_index()
	
func _on_spin_box_value_changed(value:  float) -> void:
	get_parent().move_child(self,int(value))
	host.get_parent().move_child(host,int(value))
