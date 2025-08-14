extends PropertySetUI
var can_add_change:=false
var x_all_ready:=false
var y_all_ready:=false
func _ready() -> void:
	update()
	super._ready()
func _on_spin_boxX_value_changed(new_value:  float) -> void:
	_if_null()
	x_all_ready=true
	value.x=new_value
	if !can_add_change&&!add_change_lock:
		can_add_change=true
		if x_all_ready&&y_all_ready:
			old=value
	else:
		$Timer.start(Global.constantly_changing_frozen_time)
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
	y_all_ready=true
	value.y=new_value
	if !can_add_change&&!add_change_lock:
		can_add_change=true
		if x_all_ready&&y_all_ready:
			old=value
	else:
		$Timer.start(Global.constantly_changing_frozen_time)
func _if_null()->void:
	if value==null:
		value=Vector2()


func _on_timer_timeout() -> void:
	if can_add_change:
		add_unredo()
		can_add_change=false
