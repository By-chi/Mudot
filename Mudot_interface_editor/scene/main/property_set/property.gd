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
var add_change_lock:=false
func update()->void:
	pass
var value:
	set(new_value):
		if value!=new_value:
			value=new_value
			host.set(property_name,new_value)
var old
func add_unredo()->void:
	Global.unredo.create_action("action")
	Global.unredo.add_do_method(
		set_host_value.bind(value)
	)
	Global.unredo.add_undo_method(
		set_host_value.bind(old)
	)
	Global.unredo.commit_action(false)
func set_host_value(new_value)->void:
	host.set(property_name,new_value)
	add_change_lock=true
	update()
	add_change_lock=false
