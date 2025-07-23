extends Control

@export var music_list_gui:VBoxContainer

func dataup_current_music_path_list(music_path_list:=PackedStringArray())->void:
	if music_path_list==PackedStringArray():
		current_music_path_list=Global.get_configfile(
			"music_list",
			$"../TitleBar/HBoxContainer".get_child($"../TitleBar".current_fvorite_id).name,
			PackedStringArray()
		)
	else:
		current_music_path_list=music_path_list
	updata_music_list()

func _ready() -> void:
	$"..".page=self
	_on_main_resized()
	get_tree().auto_accept_quit=false
	dataup_current_music_path_list()
	
func _on_main_resized() -> void:
#region 调整光盘位置和大小，最好不要更改，很乱
	$Panel2/Panel.size=Vector2i.ONE*($Panel2.size.y-20)
	$Panel2/Panel.position.x=$Panel2.size.x-$Panel2/Panel.size.x/2
	var new_stylebox_panel = $Panel2/Panel.get_theme_stylebox("panel").duplicate()
	new_stylebox_panel.corner_radius_top_left = $Panel2/Panel.size.x/2
	new_stylebox_panel.corner_radius_bottom_left = $Panel2/Panel.size.x/2
	$Panel2/Panel.add_theme_stylebox_override("panel", new_stylebox_panel)
	new_stylebox_panel = $Panel2/Panel/Panel.get_theme_stylebox("panel").duplicate()
	new_stylebox_panel.corner_radius_top_left = $Panel2/Panel.size.x/6
	new_stylebox_panel.corner_radius_bottom_left = $Panel2/Panel.size.x/6
	$Panel2/Panel/Panel.add_theme_stylebox_override("panel", new_stylebox_panel)
	$Panel2/Panel/Panel.size=$Panel2/Panel.size/3
	$Panel2/Panel/Panel.position=$Panel2/Panel.size/3
	new_stylebox_panel = $Panel2/Panel/Panel/Panel2.get_theme_stylebox("panel").duplicate()
	new_stylebox_panel.corner_radius_top_left = $Panel2/Panel/Panel.size.x/6
	new_stylebox_panel.corner_radius_bottom_left = $Panel2/Panel/Panel.size.x/6
	$Panel2/Panel/Panel/Panel2.add_theme_stylebox_override("panel", new_stylebox_panel)
	$Panel2/Panel/Panel/Panel2.size=$Panel2/Panel/Panel.size/3
	$Panel2/Panel/Panel/Panel2.position=$Panel2/Panel/Panel.size/3
#endregion
func add_file():
	DisplayServer.file_dialog_show(
		"请选择要导入的音乐包引导文件",Global.get_configfile("file_memory","file_path",""),"",false,
		DisplayServer.FILE_DIALOG_MODE_OPEN_FILES,
		["*.mudot"],Callable(self, "import_file")
	)
var current_music_path_list:=PackedStringArray()
func updata_music_list()->void:
	for i in music_list_gui.get_children():
		i.name="null"
		music_list_gui.remove_child(i)
		i.queue_free()
	
	for i in current_music_path_list:
		var music_tab_element=preload("res://scene/main/music_tab_element.tscn").instantiate()
		music_tab_element.connect("mouse_entered",$Panel2.show_music_detail.bind(i))
		music_tab_element.path=i
		music_tab_element.pivot_offset=Vector2(0,music_tab_element.size.y/2)
		music_list_gui.add_child(music_tab_element)
	$Panel3/MusicList/AnimationPlayer.play("start")
@warning_ignore("unused_parameter")
func import_file(status: bool, selected_paths: PackedStringArray, selected_filter_index: int):
	if status:
		for path in selected_paths:
			Global.set_configfile("file_memory","file_path",path)
			current_music_path_list.append(path)
			updata_music_list()
			Global.set_configfile(
				"music_list",
				$"../TitleBar/HBoxContainer".get_child($"../TitleBar".current_fvorite_id).name,
				current_music_path_list
			)
var last_music_tab_element:Panel:
	set(value):
		if last_music_tab_element!=value:
			if last_music_tab_element!=null&&last_music_tab_element.get_node("ColorRect").scale.x==1.0:
				last_music_tab_element._on_back_pressed()
			last_music_tab_element=value
