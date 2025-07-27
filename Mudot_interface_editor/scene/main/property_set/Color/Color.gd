extends PropertySetUI
func _ready() -> void:
	update()
	super._ready()
	
func _on_color_picker_button_color_changed(color:  Color) -> void:
	value=color
func update()->void:
	var new_value
	new_value=host.get(property_name)
	$ColorPickerButton.color=new_value
	value=new_value
