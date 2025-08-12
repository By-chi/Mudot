extends PropertySetUI

func _ready() -> void:
	update()
	super._ready()
func _on_spin_box_value_changed(new_value:  float) -> void:
	value=new_value
func update()->void:
	var new_value
	new_value=host.get(property_name)
	if new_value==null:
		new_value=float()
	$SpinBox.value=new_value
	value=new_value
