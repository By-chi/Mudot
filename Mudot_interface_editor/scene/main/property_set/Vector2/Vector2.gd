extends PropertySetUI
func _ready() -> void:
	update()
	super._ready()
func _on_spin_boxX_value_changed(new_value:  float) -> void:
	_if_null()
	value.x=new_value
func update()->void:
	var new_value:Vector2
	new_value=host.get(property_name)
	if new_value==null:
		new_value=Vector2()
	$SpinBoxX.value=new_value.x
	$SpinBoxY.value=new_value.y
	value=Vector2($SpinBoxX.value,$SpinBoxY.value)
func _on_spin_boxY_value_changed(new_value:  float) -> void:
	_if_null()
	value.y=new_value
func _if_null()->void:
	if value==null:
		value=Vector2()
