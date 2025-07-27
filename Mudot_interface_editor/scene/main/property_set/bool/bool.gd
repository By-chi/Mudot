extends PropertySetUI
func _ready() -> void:
	update()
	super._ready()
func update()->void:
	var new_value
	new_value=host.get(property_name)
	$CheckButton.button_pressed=new_value
	value=bool(new_value)
func _on_check_button_toggled(new_value:  bool) -> void:
	value=new_value
