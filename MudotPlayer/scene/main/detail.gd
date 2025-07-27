extends Panel
var template_path:=""
func show_music_detail(path:String)->void:
	Global.current_mudot_file_path=path
	var file=FileAccess.open(path,FileAccess.READ)
	if file==null:
		return
	var data = JSON.parse_string(file.get_as_text())
	file.close()
	if data==null:
		return
	template_path=path.get_base_dir()+"/"+data["template_path"]
	$Name.text=data["song_name"]
	$Singer.text=data["singer"]
	$Duration.text=data["duration"]
	$Introduction.text=data["introduction"]
	$Introduction.add_theme_color_override("font_color",Color(data["introduction_color"]))
	$"../Panel2/Panel/TextureRect".texture=Global.load_image_from_absolute_path(path.get_base_dir()+"/"+data["CD_cover_path"])

var to_show_play_button:=false
var start_positionX:float
var obstructive_lenght:=0.0:
	set(value):
		obstructive_lenght=value
		$Panel/Panel/Panel2.position.x=start_positionX-obstructive_lenght*$Panel/Panel/Panel2.size.x/2.0
	
func _on_button_mouse_entered() -> void:
	Global.show_tooltips("播放")
	to_show_play_button=true
	start_positionX=$Panel/Panel/Panel2.position.x
	set_process(true)
func _on_button_mouse_exited() -> void:
	Global.hide_tooltips()
	to_show_play_button=false
func _process(delta: float) -> void:
	if !to_show_play_button:
		if obstructive_lenght!=0.0:
			obstructive_lenght=maxf(0.0,obstructive_lenght-delta*6)
	elif to_show_play_button&&obstructive_lenght!=1.0:
			obstructive_lenght=minf(1.0,obstructive_lenght+delta*10)


func _on_button_pressed() -> void:
	if template_path=="":
		return
	$"../..".change_page(
		template_path,
		$Panel/Panel/Panel2/icon.global_position+$Panel/Panel/Panel2/icon.size/2,
		get_window().size/2.0
	)
