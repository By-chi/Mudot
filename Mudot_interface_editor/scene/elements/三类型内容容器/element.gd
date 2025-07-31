extends Element
class_name TriTypeContentContainer
func _init() -> void:
	class_name_str="TriTypeContentContainer"
	can_set_property_names={
		"size":["Vector2","尺寸",Vector2(100,100)],
		"position":["Vector2","位置"],
		"scale":["Vector2","缩放大小",Vector2.ONE],
		"rotation":["flaot","旋转(角度)"],
		"corner_radius_top_left":["float","左上角圆角半径"],
		"corner_radius_top_right":["float","右上角圆角半径"],
		"corner_radius_bottom_left":["float","左下角圆角半径"],
		"corner_radius_bottom_right":["float","右下角圆角半径"],
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
#region property
var mode_index:int:
	set(value):
		mode_index=value
		$Tailor/ColorRect.visible=$Tailor/ColorRect.get_index()==value
		$Tailor/TextureRect.visible=$Tailor/TextureRect.get_index()==value
		$Tailor/VideoStreamPlayer.visible=$Tailor/VideoStreamPlayer.get_index()==value
		$Tailor/VideoStreamPlayer.paused=!$Tailor/VideoStreamPlayer.visible
		if mode_index==2:
			$Tailor/VideoStreamPlayer.play()
		else:
			$Tailor/VideoStreamPlayer.paused=true
var color:Color:
	set(value):
		color=value
		$Tailor/ColorRect.color=value
		
var picture_path:String:
	set(value):
		picture_path=value
		if picture_path!="":
			$Tailor/TextureRect.texture=Global.load_image_from_absolute_path(
				Global.current_mudot_file_path.get_base_dir()+"/"+value
			)
var video_path:String:
	set(value):
		video_path=value
		if video_path!="":
			$Tailor/VideoStreamPlayer.stream.file=Global.current_mudot_file_path.get_base_dir()+"/"+value
			if mode_index==2:
				$Tailor/VideoStreamPlayer.play()
var picture_expand_mode:int:
	set(value):
		picture_expand_mode=value
		$Tailor/TextureRect.expand_mode=value
var picture_stretch_mode:int:
	set(value):
		picture_stretch_mode=value
		$Tailor/TextureRect.stretch_mode=value
var video_expand:int:
	set(value):
		video_expand=value
		$Tailor/VideoStreamPlayer.expand=value
var corner_radius_top_left:float:
	set(value):
		corner_radius_top_left=value
		var new_stylebox_normal = $Tailor.get_theme_stylebox("panel").duplicate()
		new_stylebox_normal.corner_radius_top_left=corner_radius_top_left
		$Tailor.add_theme_stylebox_override("panel", new_stylebox_normal)
var corner_radius_top_right:float:
	set(value):
		corner_radius_top_right=value
		var new_stylebox_normal = $Tailor.get_theme_stylebox("panel").duplicate()
		new_stylebox_normal.corner_radius_top_right=corner_radius_top_right
		$Tailor.add_theme_stylebox_override("panel", new_stylebox_normal)
var corner_radius_bottom_left:float:
	set(value):
		corner_radius_bottom_left=value
		var new_stylebox_normal = $Tailor.get_theme_stylebox("panel").duplicate()
		new_stylebox_normal.corner_radius_bottom_left=corner_radius_bottom_left
		$Tailor.add_theme_stylebox_override("panel", new_stylebox_normal)
var corner_radius_bottom_right:float:
	set(value):
		corner_radius_bottom_right=value
		var new_stylebox_normal = $Tailor.get_theme_stylebox("panel").duplicate()
		new_stylebox_normal.corner_radius_bottom_right=corner_radius_bottom_right
		$Tailor.add_theme_stylebox_override("panel", new_stylebox_normal)
#endregion


func _on_video_stream_player_finished() -> void:
	$Tailor/VideoStreamPlayer.play()
