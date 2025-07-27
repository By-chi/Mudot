extends Label
class_name PropertySetUI
var property_name:=""
@export var host:Node
var tool_tip_text:=""
func _ready() -> void:
	mouse_filter=Control.MOUSE_FILTER_STOP
	text_overrun_behavior=TextServer.OVERRUN_TRIM_CHAR
	text=property_name.to_pascal_case()
	connect("mouse_entered",mouse_entered)
	connect("mouse_exited",mouse_exited)
func mouse_entered()->void:
	Global.show_tooltips(tool_tip_text)
func mouse_exited()->void:
	Global.hide_tooltips()
var value:
	set(new_value):
		if value!=new_value:
			value=new_value
			host.set(property_name,new_value)
