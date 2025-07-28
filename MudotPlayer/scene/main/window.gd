extends Panel
var can_resize_window:=false
var start_mouse_position:Vector2i
var start_window_position:Vector2i
var start_window_size:Vector2i
var resize_direction:=Vector2i(0,0)#0:left/top,1:right/bottom
var page:Control:
	set(value):
		page=value
		$TitleBar/ExpandSidebar.visible=page.name=="Main"
		$TitleBar/HBoxContainer.visible=page.name=="Main"
		$TitleBar/Title.visible=page.name!="Main"
		$PlayerUI.visible=page.name!="Main"
func _on_window_resized()->void:
	pivot_offset=get_window().size/2

func _ready() -> void:
	get_window().min_size=Vector2i(574,574)
	var value=Global.get_configfile("window_memory","window_position",Vector2i.ZERO)
	if value!=Vector2i.ZERO:
		get_window().position=value
	value=Global.get_configfile("window_memory","window_size",Vector2i.ZERO)
	if value!=Vector2i.ZERO:
		get_window().size=value
	pivot_offset=value/2
	var args:=OS.get_cmdline_args()
	if args.size()!=0:
		var file=FileAccess.open(args[0],FileAccess.READ)
		if file==null:
			return
		var data = JSON.parse_string(file.get_as_text())
		file.close()
		if data==null:
			return
		scale=Vector2.ONE
		Global.current_mudot_file_path=args[0]
		change_page(args[0].get_base_dir()+"/"+data["template_path"],Vector2(),Vector2(),true)
func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed&&event.keycode==KEY_ESCAPE&&!$TitleBar/ExpandSidebar.visible:
			change_page("res://scene/main/main_page.tscn",get_window().size/2,get_window().size/2)
func _on_gui_input(event:  InputEvent) -> void:
	if !can_resize_window:
		if event.position.x>get_window().size.x-6:
			resize_direction.x=1
		elif event.position.x<6:
			resize_direction.x=0
		else:
			resize_direction.x=-1
		if event.position.y>get_window().size.y-6:
			resize_direction.y=1
		elif event.position.y<6:
			resize_direction.y=0
		else:
			resize_direction.y=-1
		match Vector2i(resize_direction):
			Vector2i(0, -1):  # 左边缘
				set_default_cursor_shape(Control.CURSOR_HSIZE)
			Vector2i(1, -1):  # 右边缘
				set_default_cursor_shape(Control.CURSOR_HSIZE)
			Vector2i(-1, 0):  # 上边缘
				set_default_cursor_shape(Control.CURSOR_VSIZE)
			Vector2i(-1, 1):  # 下边缘
				set_default_cursor_shape(Control.CURSOR_VSIZE)
			Vector2i(0, 0):  # 左上角落
				set_default_cursor_shape(Control.CURSOR_FDIAGSIZE)
			Vector2i(1, 1):  # 右下角落
				set_default_cursor_shape(Control.CURSOR_FDIAGSIZE)
			Vector2i(0, 1):  # 左下角落
				set_default_cursor_shape(Control.CURSOR_BDIAGSIZE)
			Vector2i(1, 0):  # 右上角落
				set_default_cursor_shape(Control.CURSOR_BDIAGSIZE)
			_:
				set_default_cursor_shape(Control.CURSOR_ARROW)
	if event is InputEventMouse:
		if Input.is_action_just_pressed("mouse_left"):
			start_mouse_position=DisplayServer.mouse_get_position()
			start_window_position=get_window().position
			start_window_size=get_window().size
			can_resize_window=true
		elif Input.is_action_just_released("mouse_left"):
			can_resize_window=false
			
		elif event is InputEventMouseMotion&&can_resize_window:
			var current_mouse_position:=DisplayServer.mouse_get_position()
			if resize_direction.x==0:
				get_window().position.x=start_window_position.x+current_mouse_position.x-start_mouse_position.x
				_set_window_size(Vector2i(start_window_size.x+start_mouse_position.x-current_mouse_position.x,get_window().size.y))
			elif resize_direction.x==1:
				_set_window_size(Vector2i(start_window_size.x+current_mouse_position.x-start_mouse_position.x,get_window().size.y))
			if resize_direction.y==0:
				get_window().position.y=start_window_position.y+current_mouse_position.y-start_mouse_position.y
				_set_window_size(Vector2i(get_window().size.x,start_window_size.y+start_mouse_position.y-current_mouse_position.y))
			elif resize_direction.y==1:
				_set_window_size(Vector2i(get_window().size.x,start_window_size.y+current_mouse_position.y-start_mouse_position.y))
func _set_window_size(value:Vector2i)->void:
	if value.x<value.y:
		get_window().size=Vector2i(value.y,value.y)
		return
	get_window().size=value
func change_page(path:String,point:Vector2,new_point:Vector2,cancel_transition_animation:=false)->void:
	$MeshInstance2D.position=point
	if !cancel_transition_animation:
		$AnimationPlayer.play("change_page")
		$AnimationPlayer.connect("animation_finished",_on_animation_player_animation_finished.bind(path,new_point),CONNECT_ONE_SHOT)
	else:
		_on_animation_player_animation_finished("change_page",path,new_point,true)
func _on_animation_player_animation_finished(anim_name:  StringName,path:String,new_point:Vector2,cancel_transition_animation:=false) -> void:
	if anim_name=="change_page":
		if !cancel_transition_animation:
			$MeshInstance2D.position=new_point
			$AnimationPlayer.play_backwards("change_page")
		var data=Global.get_data_from_json(Global.current_mudot_file_path)
		$TitleBar/Title.text=data["song_name"]+"    ----"+data["singer"]
		var new_page=load(path).instantiate()
		new_page.position=page.position
		new_page.set_deferred("size",page.size)
		new_page.clip_contents=true
		page.queue_free()
		page=new_page
		var window_size=Vector2i(int(data["suggested_window_size"][0]),int(data["suggested_window_size"][1]))
		Global.resize_window(window_size)
		add_child(new_page)
		
		if path!="res://scene/main/main_page.tscn":
			Global.load_script_variables_from_json(new_page,path.get_basename() + "_variables.json",new_page)


func _on_player_ui_visibility_changed() -> void:
	set_process(visible)
