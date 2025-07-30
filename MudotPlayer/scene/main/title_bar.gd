extends Panel
var current_fvorite_id:=0:
	set(value):
		current_fvorite_id=value
		
		$"../Main".dataup_current_music_path_list()
func _on_minimize_pressed() -> void:
	get_window().set_mode(Window.MODE_MINIMIZED)
func _on_close_pressed() -> void:
	Global.close_window()

var can_move_window:=false
var start_mouse_position:Vector2i
var start_window_position:Vector2i
func _posX_to_id(posX:float)->int:
	var spacing_distance:float=$HBoxContainer.get_theme_constant("separation")
	var x:=0.0
	for i in $HBoxContainer.get_child_count():
		x+=$HBoxContainer.get_child(i).size.x
		if x>=posX:
			if i>=$HBoxContainer.get_child_count()-2:
				return $HBoxContainer.get_child_count()-3
			return i
		x+=spacing_distance
	return $HBoxContainer.get_child_count()-3
func _on_gui_input(event:  InputEvent) -> void:
	if Input.is_action_just_pressed("mouse_left"):
		start_mouse_position=DisplayServer.mouse_get_position()
		start_window_position=get_window().position
		can_move_window=true
	elif Input.is_action_just_released("mouse_left"):
		can_move_window=false
		$HBoxContainer/LineEdit.mouse_filter=MOUSE_FILTER_STOP
		if current_button!=null&&can_move_button&&current_button.is_inside_tree():
			remove_child(current_button)
			$HBoxContainer.add_child(current_button)
			$ExpandSidebar.icon=preload("res://texture/expand.svg")
			current_button.mouse_filter=Control.MOUSE_FILTER_PASS
			var id=_posX_to_id($HBoxContainer.get_local_mouse_position().x)+1
			$HBoxContainer.move_child(current_button,id)
			var v=favorite_list[button_id-1]
			favorite_list.remove_at(button_id-1)
			favorite_list.insert(id-1,v)
			updata_favorite_list()
			Global.set_configfile("favorite_list","favorite_list",favorite_list)
		can_move_button=false
		ban_move_window=false
		current_button=null
		$Timer.stop()
	elif event is InputEventMouseMotion:
		if can_move_window&&!ban_move_window:
			var current_mouse_position:=DisplayServer.mouse_get_position()
			get_window().position=start_window_position+current_mouse_position-start_mouse_position
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if can_move_button&&current_button!=null:
			current_button.position=get_local_mouse_position()-current_button.size/2
func _on_close_mouse_entered() -> void:
	$AnimationPlayer.play("close_rotate")
	Global.show_tooltips("关闭程序")
func _on_close_mouse_exited() -> void:
	$AnimationPlayer.play_backwards("close_rotate")
	Global.hide_tooltips()
func _on_expand_sidebar_pressed() -> void:
	if !can_move_button:
		if $HBoxContainer.scale.x<=0.1:
			$AnimationPlayer.play("expand_sidebar")
		else:
			$AnimationPlayer.play_backwards("expand_sidebar")
var favorite_list:PackedStringArray
func updata_favorite_list()->void:
	for i in $HBoxContainer.get_children():
		if i is Button&&i.name!="Favorite":
			i.name="null"
			i.queue_free()
	for i in favorite_list.size():
		var button:=Button.new()
		button.name=favorite_list[i]
		button.custom_minimum_size=Vector2(50,35)
		button.text=favorite_list[i]
		button.mouse_filter=Control.MOUSE_FILTER_PASS
		button.connect("pressed",set.bind("current_fvorite_id",i+1))
		button.connect("button_down",_on_favorites_button_down.bind(button))
		$HBoxContainer.add_child(button)
		$HBoxContainer.move_child(button,-2)
		$HBoxContainer/LineEdit.text=""
func _on_line_edit_text_submitted(new_text:  String) -> void:
	if $HBoxContainer.get_node_or_null(new_text)==null:
		favorite_list.append(new_text)
		updata_favorite_list()
		Global.set_configfile("favorite_list","favorite_list",favorite_list)
		$HBoxContainer/LineEdit.release_focus()
	else:
		Global.show_hint("已有相同收藏夹")
		Global.pop("警告!","@#$^%&*$#@GH@#$%$#$647435")
func _ready() -> void:
	favorite_list=Global.get_configfile("favorite_list","favorite_list",PackedStringArray())
	updata_favorite_list()


func _on_favorite_pressed() -> void:
	current_fvorite_id=0


func _on_favorites_button_down(button:Button) -> void:
	if current_button==null:
		$Timer.start()
		current_button=button
		ban_move_window=true
var current_button:Button
var button_id:=0
var ban_move_window:=false
var can_move_button:=false
func _on_timer_timeout() -> void:
	if !can_move_button:
		can_move_button=true
		$HBoxContainer/LineEdit.mouse_filter=MOUSE_FILTER_IGNORE
		current_button.mouse_filter=Control.MOUSE_FILTER_IGNORE
		button_id=current_button.get_index()
		$HBoxContainer.remove_child(current_button)
		add_child(current_button)
		current_button.position=get_local_mouse_position()-current_button.size/2
		$ExpandSidebar.icon=preload("res://texture/delete.svg")
		
	else:
		$Timer.start()


func _on_expand_sidebar_button_up() -> void:
	if can_move_button&&current_button!=null:
		current_button.queue_free()
		favorite_list.remove_at(button_id-1)
		$HBoxContainer/LineEdit.mouse_filter=MOUSE_FILTER_STOP
		updata_favorite_list()
		Global.set_configfile("favorite_list","favorite_list",favorite_list)
		Global.set_configfile("music_list",current_button.name,null)
		
		$ExpandSidebar.icon=preload("res://texture/expand.svg")
		current_button=null


func _on_expand_sidebar_mouse_entered() -> void:
	Global.show_tooltips("收藏夹")


func _on_expand_sidebar_mouse_exited() -> void:
	Global.hide_tooltips()


func _on_minimize_mouse_entered() -> void:
	Global.show_tooltips("最小化")


func _on_minimize_mouse_exited() -> void:
	Global.hide_tooltips()
