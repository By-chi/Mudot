extends PropertySetUI
func _ready() -> void:
	update()
	super._ready()
func update()->void:
	var new_value
	new_value=host.get(property_name)
	if new_value==null:
		new_value=String()
	$TextEdit.text=new_value
	value=new_value


func _on_text_edit_text_changed() -> void:
	value=$TextEdit.text
