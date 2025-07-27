extends PropertySetUI
func _ready() -> void:
	update()
	super._ready()
func _on_line_edit_text_submitted(new_text:  String) -> void:
	value=new_text
func update()->void:
	var new_value
	new_value=host.get(property_name)
	$LineEdit.text=new_value
	value=new_value
