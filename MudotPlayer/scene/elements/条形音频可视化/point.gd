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
func _process(delta: float) -> void:
	if is_drag:
		position=get_parent().get_local_mouse_position()-size/2
		host.points[get_index()]=position+size/2
		host.update_lines()
var is_drag:=false:
	set(value):
		is_drag=value
func _on_button_down() -> void:
	is_drag=true
