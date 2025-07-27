extends Panel
var host:Control
var is_doubel_ing:=false

func _on_button_pressed() -> void:
	if is_doubel_ing:
		$Button.mouse_filter=MOUSE_FILTER_IGNORE
		$LineEdit.show()
		is_doubel_ing=false
	Global.main_node.inspectoscope.show_inspectoscope(host)
	$Doubel.start()
	is_doubel_ing=true
func _ready() -> void:
	$Label.text=host.name
	$LineEdit.text=host.name

func _on_doubel_timeout() -> void:
	is_doubel_ing=false


func _on_line_edit_text_submitted(new_text:  String) -> void:
	if new_text.is_valid_filename():
		$Label.text=new_text
		host.name=new_text
		$LineEdit.hide()
		$Button.mouse_filter=MOUSE_FILTER_STOP
func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if Input.is_action_just_released("mouse_right"):
			$Menu.visible=!$Menu.visible


func _on_remove_pressed() -> void:
	host.quit()
