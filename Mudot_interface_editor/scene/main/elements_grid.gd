extends GridContainer
func update()->void:
	for i in ResourceLoader.list_directory(Global.ELEMENTS_DIR_PATH):
		if !i.is_valid_filename():
			var node=preload("res://scene/main/element_ui_button.tscn").instantiate()
			node.text=i.trim_suffix("/")
			node.connect("pressed",add_element.bind(Global.ELEMENTS_DIR_PATH+i))
			add_child(node)
func add_element(path:String)->void:
	var node=load(path+"element.tscn").instantiate()
	Global.main_node.main_scene.add_child(node)
