extends PropertySetUI
func _ready() -> void:
	update()
	super._ready()
func update()->void:
	var new_value
	new_value=host.get(property_name)
	if new_value==null:
		new_value=bool()
	$CheckButton.button_pressed=new_value
	value=bool(new_value)

func _on_check_button_pressed() -> void:
	old=value
	value=$CheckButton.button_pressed
	add_unredo()
