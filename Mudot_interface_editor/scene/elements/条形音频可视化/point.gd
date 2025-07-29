extends Button
var host:Control
func _ready() -> void:
	host=get_parent().get_parent()
	relative_offset_x = $LineEditY.position.x - $LineEditX.position.x
	original_x_pos=$LineEditX.position
	original_y_pos=$LineEditY.position
	check_position()
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
func check_position():
	var constraint_position = Global.main_node.main_scene.global_position
	if $LineEditX.global_position.x<constraint_position.x:
		$LineEditX.global_position.x=constraint_position.x
		$LineEditY.global_position.x=constraint_position.x+relative_offset_x
		last_x_pos=$LineEditX.global_position
		last_y_pos=$LineEditY.global_position
	if $LineEditX.global_position.y<constraint_position.y:
		$LineEditX.global_position.y=constraint_position.y
		$LineEditY.global_position.y=constraint_position.y
		last_x_pos=$LineEditX.global_position
		last_y_pos=$LineEditY.global_position
	if global_position.x+original_x_pos.x<constraint_position.x:
		$LineEditX.global_position.x=last_x_pos.x
		$LineEditY.global_position.x=last_y_pos.x
	else:
		$LineEditX.position.x=original_x_pos.x
		$LineEditY.position.x=original_y_pos.x
	if global_position.y+original_x_pos.y<constraint_position.y:
		$LineEditX.global_position.y=last_x_pos.y
		$LineEditY.global_position.y=last_y_pos.y
	else:
		$LineEditX.position.y=original_x_pos.y
		$LineEditY.position.y=original_y_pos.y
var original_x_pos:Vector2
var original_y_pos:Vector2
var last_x_pos:Vector2
var last_y_pos:Vector2
var relative_offset_x:float
func _process(delta: float) -> void:
	if is_drag:
		_set_pos(get_parent().get_local_mouse_position()-size/2)
func _set_pos(pos:Vector2)->void:
	last_x_pos=$LineEditX.global_position
	last_y_pos=$LineEditY.global_position
	position=pos
	check_position()
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
