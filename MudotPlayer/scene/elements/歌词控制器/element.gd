extends Element
class_name LyricController
func _init() -> void:
	class_name_str="LyricController"
	can_set_property_names={
		"lyric_path":["String","歌词文件(*.lrc)的相对于mudot所在目录的路径"],
		"offset":["float","歌词延迟偏移量,越小越提前\n※不会覆盖歌词文件(*.lrc)中的offset,而是会累积"],
		"audio":["String","音乐播放器节点(MusicPlayer)的名称,会根据此节点得到当前播放位置"],
		"style":["String","标签样式节点(LabelStyle)的名称,每行歌词都会用到"],
		"interpreter":["int","因为*.lrc文件格式有非常多的版本,所以会用不同的标准来分析文件:\n0:标准 LRC\n1:"],
		"position":["Vector2","位置"],
	}

var lyric_data:Dictionary
var label_node_list:Array[Label]
func _ready() -> void:
	super._ready()
	
#func all_ready()->void:
	#
func register_lyric_node()->Label:
	if style_node!=null:
		var label_node:Label=style_node.label.duplicate()
		add_child(label_node)
		label_node.connect("tree_exiting",label_node_list.erase.bind(label_node))
		label_node_list.append(label_node)
		return label_node
	return null
func get_current_lyric(offset_id:=0)->String:
	if lyric_data=={}||audio_node==null||audio_node.class_name_str!="MusicPlayer":
		return ""
	var offset_in_file:=0.0
	if lyric_data.has("offset"):
		offset_in_file=float(lyric_data["offset"][0][0])
	return get_lyric_by_time(audio_node.get_current_pos()+offset+offset_in_file,offset_id)
func get_lyric_by_time(time:float,offset_id:=0)->String:
	@warning_ignore("integer_division")
	var min_int:=int(time)/60
	var last_min_str:String
	if min_int > 0:
		last_min_str = str(min_int - 1).pad_zeros(2)
	else:
		last_min_str = ""
	var min_str:=str(min_int).pad_zeros(2)
	var s:float=fmod(time,60)
	if !lyric_data.has(min_str):
		return ""
	var lyric_data_size:int=lyric_data[min_str].size()
	var base_id:=0
	var base_key:=min_str
	for i in lyric_data_size:
		if float(lyric_data[min_str][i][0])>s||i==lyric_data_size-1:
			if i==0:
				if last_min_str=="":
					return ""
				base_key=last_min_str
				base_id=lyric_data[last_min_str].size()-1
				break
			elif i<lyric_data_size-1:
				base_id=i-1
				break
			else:
				base_id=i
				break
	base_id+=offset_id
	lyric_data_size=lyric_data[base_key].size()
	if base_id<0:
		base_key=str(int(base_key)-1).pad_zeros(2)
		if !lyric_data.has(base_key):
			return ""
		while true:
			base_id+=lyric_data[base_key].size()
			var key_int:=int(base_key)-1
			base_key=str(key_int).pad_zeros(2)
			if !lyric_data.has(base_key):
				return ""
			if base_id>=0:
				break
	elif base_id>=lyric_data_size:
		while true:
			base_id-=lyric_data[base_key].size()
			var key_int:=int(base_key)+1
			base_key=str(key_int).pad_zeros(2)
			if !lyric_data.has(base_key):
				return ""
			if base_id<lyric_data[base_key].size():
				break
	return lyric_data[base_key][base_id][1]
#region property
var lyric_path:String:
	set(value):
		lyric_path=value
		if lyric_path==null||lyric_path=="":
			return
		var file:=FileAccess.open(Global.current_mudot_file_path.get_base_dir()+"/"+lyric_path,FileAccess.READ)
		if file!=null:
			lyric_data.clear()
			var regex = RegEx.new()
			#[00:00.00]xxxxxxxx
			regex.compile(r"^\[(.*)\:(.*)\](.*)$")
			while not file.eof_reached():
				var line: String = file.get_line()
				if line=="":
					continue
				var reg_ex_match:= regex.search(line)
				if reg_ex_match!=null:
					# 提取三个分组
					var part1 = reg_ex_match.get_string(1).strip_edges()  # 去除边缘空格
					var part2 = reg_ex_match.get_string(2).strip_edges()  # 去除边缘空格
					var part3 = reg_ex_match.get_string(3)  # 保留原始空格
					var data_value:Array=lyric_data.get_or_add(part1,[])
					data_value.append(PackedStringArray([part2,part3]))
			file.close()
			#_print_lyric_path()
func _print_lyric_path()->void:
	for i in lyric_data:
		print(i)
		for j in lyric_data[i]:
			printt("",j[0],j[1])
var audio_node:MusicPlayer
var audio:String:
	set(value):
		audio=value
		if Global.in_editor:
			audio_node=Global.main_node.main_scene.get_node_or_null(audio)
		else:
			audio_node=get_node("/root/Panel").page.get_node_or_null(audio)
		#get_current_lyric()
var offset:float:
	set(value):
		offset=value
var style_node:LabelStyle
func style_node_ready()->void:
	for i in get_children():
		i.queue_free()
var style:String:
	set(value):
		style=value
		if style=="":
			return
		if Global.in_editor:
			style_node=Global.main_node.main_scene.get_node_or_null(style)
		else:
			style_node=get_node("/root/Panel").page.get_node_or_null(style)
		if style_node!=null:
			if !style_node.is_connected("ready",style_node_ready):
				style_node.connect("ready",style_node_ready)
			if style_node.is_node_ready():
				style_node_ready.call_deferred()
