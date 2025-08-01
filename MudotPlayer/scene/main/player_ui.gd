extends CanvasLayer
var showing:=false
var hiding:=false
var player:Control
var player_node:AudioStreamPlayer
func show_bar():
	showing=true
	hiding=false
func hide_bar():
	hiding=true
	showing=false
var showed:=false
func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed&&event.keycode==KEY_CTRL:
			showed=!showed
			if showed:
				show_bar()
			else:
				hide_bar()
func format_seconds(seconds: int) -> String:
	seconds = max(0, seconds)
	var minutes: = seconds / 60.0
	var remaining_seconds = seconds % 60
	if minutes > 0:
		if remaining_seconds>=10:
			return "%d:%d" % [minutes, remaining_seconds]
		else:
			return "%d:0%d" % [minutes, remaining_seconds]
	else:
		return str(remaining_seconds)
func _physics_process(delta: float) -> void:
	if player!=null:
		slider_value_lock=true
		$Bar/HSlider.value=(player_node.get_playback_position()/player_node.stream.get_length())*100.0
		slider_value_lock=false
		$Bar/HSlider/Time/Label.text=format_seconds($Bar/HSlider.value)
		$Bar/HSlider/Time/Label3.text=format_seconds(player_node.stream.get_length())
		
func _process(delta: float) -> void:
	if showing:
		$Bar.show()
		$Bar.size.y=$Bar.size.y*0.4+40.0*0.6
		$Bar.position.y=get_window().size.y-$Bar.size.y
	if showing&&40-$Bar.size.y<=3:
		showing=false
		$Bar.size.y=40
		$Bar.position.y=get_window().size.y-40
	if hiding:
		$Bar.size.y*=0.7
		$Bar.position.y=get_window().size.y-$Bar.size.y
	if hiding&&$Bar.size.y<=3:
		hiding=false
		$Bar.hide()
		$Bar.size.y=0
		$Bar.position.y=get_window().size.y
func _on_h_slider_resized() -> void:
	$Bar/HSlider.size.x=minf($Bar/HSlider.size.x,500)
	$Bar/HSlider.pivot_offset=$Bar/HSlider.size/2.0
	$Bar/HSlider.position=($Bar.size-$Bar/HSlider.size)/2.0

func _on_h_slider_drag_started() -> void:
	$AnimationPlayer.play("grabber")


func _on_h_slider_drag_ended(value_changed: bool) -> void:
	$AnimationPlayer.play_backwards("grabber")

var slider_value_lock:=false
func _on_h_slider_value_changed(value:float) -> void:
	if !slider_value_lock:
		get_tree().paused=false
		$Bar/HBoxContainer/Button2.icon=preload("res://texture/play.svg")
		player.current_playback_progress=value/100.0


func _on_volume_slider_value_changed(value:  float) -> void:
	AudioServer.set_bus_volume_linear(1,value/100.0)
func _on_volume_pressed() -> void:
	if $Bar/HSlider/Volume/HSlider.size.x==8.0:
		$Bar/HSlider/Volume/AnimationPlayer.play("show")
	else:
		$Bar/HSlider/Volume/AnimationPlayer.play_backwards("show")


func _on_button_last_pressed() -> void:
	var arr:PackedStringArray=Global.get_configfile("music_list",$"../TitleBar/HBoxContainer".get_child($"../TitleBar".current_fvorite_id).name)
	var index:=arr.find(Global.current_mudot_file_path)-1
	if index<-1:
		return
	var mudot_path:=arr[index]
	Global.current_mudot_file_path=mudot_path
	var data=Global.get_data_from_json(mudot_path)
	if data.has("template_path"):
		$"..".change_page(mudot_path.get_base_dir()+"/"+data["template_path"],get_window().size/2,get_window().size/2)


func _on_button_pause_pressed() -> void:
	get_tree().paused=!get_tree().paused
	if get_tree().paused==false:
		$Bar/HBoxContainer/Button2.icon=preload("res://texture/play.svg")
	else:
		$Bar/HBoxContainer/Button2.icon=preload("res://texture/pause.svg")
		


func _on_button_next_pressed() -> void:
	var arr:PackedStringArray=Global.get_configfile("music_list",$"../TitleBar/HBoxContainer".get_child($"../TitleBar".current_fvorite_id).name)
	var index:=(arr.find(Global.current_mudot_file_path)+1)%arr.size()
	if index<-1:
		return
	var mudot_path:=arr[index]
	Global.current_mudot_file_path=mudot_path
	var data=Global.get_data_from_json(mudot_path)
	if data.has("template_path"):
		$"..".change_page(mudot_path.get_base_dir()+"/"+data["template_path"],get_window().size/2,get_window().size/2)
