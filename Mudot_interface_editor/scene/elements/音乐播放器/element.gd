extends Element
class_name MusicPlayer
func _init() -> void:
	class_name_str="MusicPlayer"
	can_set_property_names={
		"music_path":["String","要播放的音乐文件相对于mudot文件所在的目录下的路径"],
		"volume_db":["float","音量，单位为分贝这是相对于 播放的音乐 音量的偏移"],
		"volume_linear":["float","线性形式的音量",1],
		"position":["Vector2","位置"],
		#"Position":["Vector2","位置"],
	}
	
func _ready() -> void:
	super._ready()
	if Global.in_editor:
		for i in Global.main_node.main_scene.get_children():
			if i.class_name_str=="MusicPlayer"&&i!=self:
				quit()
				Global.main_node.current_element=i
#region property
var music_path:String:
	set(value):
		music_path=value
		var path:=Global.current_mudot_file_path.get_base_dir()+"/"+music_path
		if music_path.ends_with("wav"):
			$AudioStreamPlayer.stream=AudioStreamWAV.load_from_file(
				path)
		elif music_path.ends_with("ogg"):
			$AudioStreamPlayer.stream=AudioStreamOggVorbis.load_from_file(
				path)
		elif music_path.ends_with("mp3"):
			var music_file = FileAccess.open(path, FileAccess.READ)
			var sound = AudioStreamMP3.new()
			sound.data = music_file.get_buffer(music_file.get_length())
			$AudioStreamPlayer.stream=sound
			music_file.close()
		if $AudioStreamPlayer.stream!=null:
			var data=Global.get_data_from_json(Global.current_mudot_file_path)
			data["duration"]=format_seconds($AudioStreamPlayer.stream.get_length())
			var file = FileAccess.open(Global.current_mudot_file_path, FileAccess.WRITE)
			if file:
				file.store_string(JSON.stringify(data, "\t"))
				file.close()
			$AudioStreamPlayer.play()
func format_seconds(seconds: int) -> String:
	# 确保输入为非负整数
	seconds = max(0, seconds)
	
	# 计算分钟和剩余秒数
	var minutes: = seconds / 60.0
	var remaining_seconds = seconds % 60
	
	# 根据是否有分钟数返回不同格式
	if minutes > 0:
		return "%d min %d s" % [minutes, remaining_seconds]
	else:
		return "%d s" % remaining_seconds
var volume_db:float:
	set(value):
		volume_db=value
		$AudioStreamPlayer.volume_db=value
var volume_linear:float:
	set(value):
		volume_linear=value
		$AudioStreamPlayer.volume_linear=value
#var Position:Vector2:
	#set(value):
		#Position=value
		#position=value
#endregion


func _on_audio_stream_player_finished() -> void:
	$AudioStreamPlayer.play()
