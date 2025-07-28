extends Button
var host:Control
func _ready() -> void:
	host=get_parent().get_parent()
func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if Input.is_action_just_pressed("mouse_right"):
			host.points.remove_at(get_index())
			queue_free()
			host.update_lines()
			
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if Input.is_action_just_released("mouse_left")&&is_drag:
			is_drag=false
		elif Input.is_action_just_released("mouse_right"):
			$LineEditX.visible=false
			$LineEditY.visible=false
func _process(delta: float) -> void:
	if is_drag:
		_set_pos(get_parent().get_local_mouse_position()-size/2)
func _set_pos(pos:Vector2)->void:
	position=pos
	host.points[get_index()]=position+size/2
	host.update_lines()
	$LineEditX.text=str(pos.x)
	$LineEditY.text=str(pos.y)
var is_drag:=false:
	set(value):
		is_drag=value
func _on_button_down() -> void:
	if Global.main_node.tool_bar.current_index==0:
		is_drag=true
		$LineEditX.visible=true
		$LineEditY.visible=true

func _on_line_edit_x_text_submitted(new_text:  String) -> void:
	_set_pos(Vector2(new_text.to_float(),position.y))


func _on_line_edit_y_text_submitted(new_text:  String) -> void:
	_set_pos(Vector2(position.x,new_text.to_float()))
