extends Element
class_name Background
func _init() -> void:
	class_name_str="Background"
	can_set_property_names={
		"mode_index":["int","显示模式\n0:纯色模式\n1:图片模式\n2:视频模式"],
		"color":["Color","纯色模式下背景的颜色"],
		"picture_path":["String","图片模式下背景的图片的相对于mudot所在目录的路径"],
		"video_path":["String","视频模式下背景的图片的相对于mudot所在目录的路径"],
		"video_expand":["bool","视频模式下,如果为 True，视频会缩放到控件的尺寸。否则，控件的最小尺寸将被自动调整以匹配视频流的尺寸"],
		"picture_expand_mode":["int","图片模式下背景的扩展模式\n0:最小尺寸将等于纹理尺寸，即 TextureRect 不能小于纹理
1:纹理尺寸不会用于计算最小尺寸，所以 TextureRect 可以缩减得比纹理尺寸小
2:会忽略纹理的高度最小宽度与当前高度一致可用于横向布局，例如在 HBoxContainer 中
3:与 2 相同，但保持纹理的长宽比
4:会忽略纹理的宽度最小高度与当前宽度一致可用于纵向布局，例如在 VBoxContainer 中
5:与 4 相同，但保持纹理的长宽比"],
		"picture_stretch_mode":["int","图片模式下的拉伸模式\n0:缩放以适应节点的边界矩形
1:在节点的边界矩形内平铺
2:纹理保持它的原始尺寸，并保持在边界矩形的左上角
3:纹理保持其原始大小，并在节点的边界矩形中保持居中
4:缩放纹理以适应节点的边界矩形，但保持纹理的长宽比
5:缩放纹理以适应节点的边界矩形，使其居中并保持其长宽比
6:缩放纹理，使较短的一边适应边界矩形另一边则裁剪到节点的界限内"],
	}
func _ready() -> void:
	super._ready()
	if Global.in_editor:
		for i in Global.main_node.main_scene.get_children():
			if i.class_name_str=="Background"&&i!=self:
				quit()
				Global.main_node.current_element=i
#region property
var mode_index:int:
	set(value):
		mode_index=value
		$ColorRect.visible=$ColorRect.get_index()==value
		$TextureRect.visible=$TextureRect.get_index()==value
		$VideoStreamPlayer.visible=$VideoStreamPlayer.get_index()==value
		$VideoStreamPlayer.paused=!$VideoStreamPlayer.visible
		if mode_index==2:
			$VideoStreamPlayer.play()
		else:
			$VideoStreamPlayer.paused=true
var color:Color:
	set(value):
		color=value
		$ColorRect.color=value
		
var picture_path:String:
	set(value):
		picture_path=value
		if picture_path!="":
			$TextureRect.texture=Global.load_image_from_absolute_path(
				Global.current_mudot_file_path.get_base_dir()+"/"+value
			)
var video_path:String:
	set(value):
		video_path=value
		if video_path!="":
			$VideoStreamPlayer.stream.file=Global.current_mudot_file_path.get_base_dir()+"/"+value
			if mode_index==2:
				$VideoStreamPlayer.play()
var picture_expand_mode:int:
	set(value):
		picture_expand_mode=value
		$TextureRect.expand_mode=value
var picture_stretch_mode:int:
	set(value):
		picture_stretch_mode=value
		$TextureRect.stretch_mode=value
var video_expand:int:
	set(value):
		video_expand=value
		$VideoStreamPlayer.expand=value
#endregion


func _on_video_stream_player_finished() -> void:
	$VideoStreamPlayer.play()
