extends CanvasLayer
@export var vBoxContainer:VBoxContainer
func show_on(text:String,color:=Color.GREEN,index:=0)->void:
	var count=index-vBoxContainer.get_child_count()+1
	if count>0:
		for i in count:
			var label:=Label.new()
			label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
			vBoxContainer.add_child(label)
	vBoxContainer.get_child(index).text=text
	vBoxContainer.get_child(index).modulate=color
