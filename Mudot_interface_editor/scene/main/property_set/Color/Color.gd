extends PropertySetUI
func _ready() -> void:
	update()
	super._ready()
	
func _on_color_picker_button_color_changed(color:  Color) -> void:
	value=color
func update()->void:
	var new_value
	new_value=host.get(property_name)
	if new_value==null:
		new_value=Color()
	$ColorPickerButton.color=new_value
	value=new_value
func _on_color_picker_button_popup_closed() -> void:
	add_unredo()


func _on_color_picker_button_picker_created() -> void:
	old=value
