extends Panel

func _on_mouse_entered() -> void:
	$AnimationPlayer.play("hover")
	to_show=true
func _on_mouse_exited() -> void:
	$AnimationPlayer.play_backwards("hover")
	to_show=false
var to_show:=false
var speed:=6.0
var obstructive_lenght:=0.0:
	set(value):
		$TextureRect/ColorRect.material.set_shader_parameter("progress",value)
		var new_stylebox_panel = get_theme_stylebox("panel").duplicate()
		new_stylebox_panel.corner_radius_top_left = 30+value*10.0
		new_stylebox_panel.corner_radius_bottom_left = 30+value*10.0
		new_stylebox_panel.corner_radius_top_right = 30+value*10.0
		new_stylebox_panel.corner_radius_bottom_right = 30+value*10.0
		add_theme_stylebox_override("panel", new_stylebox_panel)
		$Button.modulate.a=1.0-value
		obstructive_lenght=value
func _process(delta: float) -> void:
	if to_show&&obstructive_lenght!=2.0:
		obstructive_lenght=minf(2.0,obstructive_lenght+delta*speed)
	elif !to_show:
		if obstructive_lenght!=0:
			obstructive_lenght=maxf(0.0,obstructive_lenght-delta*speed)
	if can_move:
		get_parent().get_node("ScrollContainer").scroll_vertical-=(start_mouseY-DisplayServer.mouse_get_position().y)*6.0*delta
var path:String
func _ready() -> void:
	$TextureRect/ColorRect.material=$TextureRect/ColorRect.material.duplicate()
	init_data()
func init_data()->void:
	var file=FileAccess.open(path,FileAccess.READ)
	if file==null:
		return
	var data = JSON.parse_string(file.get_as_text())
	file.close()
	if data==null:
		return
	$TextureRect/ColorRect/Name.text=data["name"]
	$TextureRect/ColorRect/Name/Singer.text=data["singer"]
	$TextureRect.texture=Global.load_image_from_absolute_path(path.get_base_dir()+"/"+data["list_cover_path"])

func _on_button_pressed() -> void:
	$AnimationPlayer2.play("edit")
	get_node("/root/Panel/Main").last_music_tab_element=self


func _on_back_pressed() -> void:
	$AnimationPlayer2.play_backwards("edit")

var can_move:=false
func _on_move_pressed() -> void:
	can_move=true
	mouse_filter=Control.MOUSE_FILTER_IGNORE
	start_button_id=get_index()
	var new_parent:=get_node("/root/Panel/Main/Panel3/MusicList")
	get_parent().remove_child(self)
	new_parent.add_child(self)
	z_index=998
	position=get_node("/root/Panel/Main/Panel3/MusicList").get_local_mouse_position()-$ColorRect/HBoxContainer/Move.global_position+global_position-$ColorRect/HBoxContainer/Move.size/2
	start_mouseY=DisplayServer.mouse_get_position().y
var start_mouseY:float
var start_button_id:=0
func _input(event: InputEvent) -> void:
	if can_move:
		if event is InputEventMouseMotion:
			if can_move:
				position=get_node("/root/Panel/Main/Panel3/MusicList").get_local_mouse_position()-$ColorRect/HBoxContainer/Move.global_position+global_position-$ColorRect/HBoxContainer/Move.size/2
		elif event is InputEventMouseButton:
			if Input.is_action_just_released("mouse_left"):
				can_move=false
				mouse_filter=Control.MOUSE_FILTER_STOP
				z_index=0
				var new_parent:=get_node("/root/Panel/Main/Panel3/MusicList/ScrollContainer/VBoxContainer")
				get_parent().remove_child(self)
				new_parent.add_child(self)
				var id:=_posY_to_id(get_parent().get_local_mouse_position().y)
				new_parent.move_child(self,id)
				
				var main=get_node("/root/Panel/Main")
				var v=main.current_music_path_list[start_button_id]
				main.current_music_path_list.remove_at(start_button_id)
				main.current_music_path_list.insert(id,v)
				Global.set_configfile(
					"music_list",
					get_node("/root/Panel/TitleBar/HBoxContainer").get_child(get_node("/root/Panel/TitleBar").current_fvorite_id).name,
					main.current_music_path_list
				)
func _on_remove_pressed() -> void:
	var main=get_node("/root/Panel/Main")
	main.current_music_path_list.remove_at(get_index())
	Global.set_configfile(
		"music_list",
		get_node("/root/Panel/TitleBar/HBoxContainer").get_child(get_node("/root/Panel/TitleBar").current_fvorite_id).name,
		main.current_music_path_list
	)
	queue_free()
func _posY_to_id(posY:float)->int:
	var spacing_distance:float=get_parent().get_theme_constant("separation")
	var y:=0.0
	for i in get_parent().get_child_count():
		y+=get_parent().get_child(i).size.y
		if y-spacing_distance-get_parent().get_child(i).size.y/2>=posY:
			return i
		y+=spacing_distance
	return get_parent().get_child_count()-1
