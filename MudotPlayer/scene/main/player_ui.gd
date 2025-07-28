extends CanvasLayer
var showing:=false
var hiding:=false
func show_bar():
	showing=true
	hiding=false
func hide_bar():
	hiding=true
	showing=false
func _process(delta: float) -> void:
	if showing:
		$Bar.size.y=$Bar.size.y*0.8+40.0*0.2
		$Bar.position.y=get_window().size.y-$Bar.size.y
	if showing&&40-$Bar.size.y<=3:
		showing=false
		$Bar.size.y=40
		$Bar.position.y=get_window().size.y-40
	elif hiding:
		$Bar.size.y*=0.7
		$Bar.position.y=get_window().size.y-$Bar.size.y
	elif hiding&&$Bar.size.y<=3:
		hiding=false
		$Bar.size.y=0
		$Bar.position.y=get_window().size.y




func _on_control_mouse_entered() -> void:
	show_bar()


func _on_control_mouse_exited() -> void:
	hide_bar()
