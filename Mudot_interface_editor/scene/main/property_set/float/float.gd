extends PropertySetUI
var can_add_change:=false
func _ready() -> void:
	update()
	super._ready()
func _on_spin_box_value_changed(new_value:  float) -> void:
	value=new_value
	if !can_add_change&&!add_change_lock:
		can_add_change=true
		old=value
	else:
		$Timer.start(Global.constantly_changing_frozen_time)
		
func update()->void:
	var new_value
	new_value=host.get(property_name)
	if new_value==null:
		new_value=float()
	$SpinBox.value=new_value
	value=new_value


func _on_timer_timeout() -> void:
	add_unredo()
	can_add_change=false
