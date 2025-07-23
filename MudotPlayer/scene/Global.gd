extends Node

#region save

var user_leven:
	set(value):
		user_leven=value
		set_configfile("user","user_leven",user_leven)
const CONFIG_FILE_PATH:="user://config.cfg"
func set_configfile(section: String, key: String, value: Variant)->void:
	create_if_missing(CONFIG_FILE_PATH)
	var cfg:=ConfigFile.new()
	cfg.load(CONFIG_FILE_PATH)
	cfg.set_value(section,key,value)
	cfg.save(CONFIG_FILE_PATH)
func get_configfile(section: String, key: String,default: Variant = null)->Variant:
	create_if_missing(CONFIG_FILE_PATH)
	var cfg:=ConfigFile.new()
	cfg.load(CONFIG_FILE_PATH)
	return cfg.get_value(section,key,default)

func close_window()->void:
	set_configfile("window_memory","window_position",get_window().position)
	set_configfile("window_memory","window_size",get_window().size)
	get_node("/root/Panel/AnimationPlayer").play_backwards("start")
	get_node("/root/Panel/AnimationPlayer").connect("animation_finished",get_tree().quit)
static func create_if_missing(path:String)->void:
	var exists = DirAccess.dir_exists_absolute(path) || FileAccess.file_exists(path)
	if exists:
		return
	if path.ends_with("/"):
		DirAccess.make_dir_recursive_absolute(path)
	else:
		if !DirAccess.dir_exists_absolute(path.get_base_dir()):
			DirAccess.make_dir_recursive_absolute(path.get_base_dir())
		var file=FileAccess.open(path,FileAccess.WRITE)
		FileAccess.get_open_error()
		file.close()
#endregion



#region pop
func pop(title:String,text:String)->void:
	$ColorRect/Pop/AnimationPlayer.play("show")
	$ColorRect/Pop/Title.text=title
	$ColorRect/Pop/Text.text=text

func _on_button_pressed() -> void:
	$ColorRect/Pop/AnimationPlayer.play_backwards("show")
func show_hint(text:String)->void:
	$Hint/Label.text=text
	$Hint/AnimationPlayer.play("show")
	$Hint/Timer.start(2.0)
	$Hint.size.x=$Hint/Label.text.length()*25+20
	$Hint.pivot_offset=$Hint.size/2
func _on_timer_timeout() -> void:
	$Hint/AnimationPlayer.play_backwards("show")

func show_tooltips(text:String)->void:
	$ToolTips/Timer.start()
	$ToolTips/Timer.connect("timeout",_on_tooltips_timer_timeout.bind(text),CONNECT_ONE_SHOT)
func hide_tooltips()->void:
	if $ToolTips/Timer.is_stopped():
		$ToolTips/AnimationPlayer.play_backwards("show")
	else:
		$ToolTips/Timer.stop()
		$ToolTips/Timer.disconnect("timeout",_on_tooltips_timer_timeout)
func _on_tooltips_timer_timeout(text:String) -> void:
	$ToolTips/AnimationPlayer.play("show")
	$ToolTips/Label.text=text
	var texts:=text.rsplit("\n")
	var l:=0
	for i in texts:
		l=max(l,i.length())
	$ToolTips.size.x=20+l*21
	$ToolTips.size.y=20+texts.size()*23
	$ToolTips.global_position.x=max(min(get_viewport().get_mouse_position().x,get_window().size.x-$ToolTips.size.x-10),10)
	$ToolTips.global_position.y=max(min(get_viewport().get_mouse_position().y-53,get_window().size.y-$ToolTips.size.y-10),0)
#endregion
#region file_load
func load_image_from_absolute_path(path: String) -> Texture2D:
	var image = Image.new()
	var err = image.load(path)
	if err != OK:
		return null
	var texture = ImageTexture.create_from_image(image)
	return texture
 
#endregion
func _ready() -> void:
	get_window().connect("close_requested",close_window)
	
