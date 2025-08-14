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
func get_current_pos()->float:
	return $AudioStreamPlayer.get_playback_position()+AudioServer.get_time_since_last_mix()
var current_playback_progress:=0.0:
	set(value):
		current_playback_progress=value
		if $AudioStreamPlayer.stream!=null:
			$AudioStreamPlayer.seek($AudioStreamPlayer.stream.get_length()*current_playback_progress)
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
		music_path=value.strip_edges()
		var path:=Global.current_mudot_file_path.get_base_dir()+"/"+music_path
		if music_path.ends_with("wav"):
			$AudioStreamPlayer.stream=AudioStreamWAV.load_from_file(
				path)
		elif music_path.ends_with("ogg"):
			$AudioStreamPlayer.stream=AudioStreamOggVorbis.load_from_file(
				path)
		elif music_path.ends_with("mp3"):
			print(path)
			var music_file = FileAccess.open(path, FileAccess.READ)
			if music_file!=null:
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
	seconds = max(0, seconds)
	var minutes: = seconds / 60.0
	var remaining_seconds = seconds % 60
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
#endregion


func _on_audio_stream_player_finished() -> void:
	$AudioStreamPlayer.play()
