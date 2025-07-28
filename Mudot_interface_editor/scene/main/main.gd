extends Panel
@export var inspectoscope:Panel
@export var property_list:VBoxContainer
@export var elements:Panel
@export var element_node_list:Panel
@export var tool_bar:HBoxContainer
@export var main_scene:Control:
	set(value):
		main_scene=value
		main_scene.z_index=1
		main_scene.connect("mouse_entered",Callable(tool_bar,"main_scene_mouse_entered"))
		main_scene.connect("mouse_exited",Callable(tool_bar,"main_scene_mouse_exited"))
var current_element:Control:
	set(value):
		if value!=null:
			current_element=value
			Global.select_control_box(current_element)
		else:
			inspectoscope.hide_inspectoscope()
func _ready() -> void:
	Global.main_node=self
	elements.update()
	Global.load_scene_from_mudot(Global.current_mudot_file_path)
