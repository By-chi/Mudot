extends Element
class_name LabelStyle
@onready var label:Label=$Label
func _init() -> void:
	class_name_str="LabelStyle"
	can_set_property_names={
		"text":["String","文本","Hello Mudot"],
		"uppercase":["bool","如果为 true，所有文本都将显示为大写"],
		"font_color":["Color","文本颜色",Color.WHITE],
		"font_shadow_color":["Color","阴影颜色",Color.TRANSPARENT],
		"font_outline_color":["Color","边框颜色"],
		"line_spacing":["int","行与行之间的额外纵向留白（单位为像素），留白会被添加到行的降部.该值可以为负数",3],
		"paragraph_spacing":["int","段落之间的垂直空间"],
		"shadow_offset_x":["int","文本阴影的水平偏移"],
		"shadow_offset_y":["int","文本阴影的垂直偏移"],
		"outline_size":["int","文字轮廓的大小"],
		"shadow_outline_size":["int","阴影轮廓的大小"],
		"font_file_path":["String","文本的字体文件相对于modut文件所在目录的路径\n默认字体为\"JetBrainsMonoNL-Regular\""],
		"font_size":["int","文本的字体大小",30],
		"release_visible":["bool","如果为 false 则在播放器中运行时隐藏\n这可以用来给歌词控制器(LyricController)提供样式并且不显示自身",true],
		"position":["Vector2","位置"]
	}

func _ready() -> void:
	super._ready()
func load_font() -> Font:
	if font_file_path and font_file_path != "":
		return ResourceLoader.load(Global.current_mudot_file_path.get_base_dir() + "/" + font_file_path,"Font")
	return label.get_theme_font("font")

#region property
var text:String:
	set(value):
		text=value
		if label!=null:
			label.text=text
var uppercase:bool:
	set(value):
		uppercase=value
		if label!=null:
			label.uppercase=uppercase

var font_size: int:
	set(value):
		font_size = value
		if label!=null:
			label.add_theme_font_size_override("font_size", font_size)

var font_color: Color:
	set(value):
		font_color = value
		if label!=null:
			label.add_theme_color_override("font_color", font_color)
var font_shadow_color: Color:
	set(value):
		font_shadow_color = value
		if label!=null:
			label.add_theme_color_override("font_shadow_color", font_shadow_color)
var font_file_path: String:
	set(value):
		font_file_path = value
		if label!=null:
			label.add_theme_font_override("font", load_font())

var shadow_color: Color:
	set(value):
		shadow_color = value
		if label!=null:
			label.add_theme_color_override("shadow_color", shadow_color)
var font_outline_color: Color:
	set(value):
		font_outline_color = value
		if label!=null:
			label.add_theme_color_override("font_outline_color", font_outline_color)
var shadow_offset_x: int:
	set(value):
		shadow_offset_x = value
		if label!=null:
			label.add_theme_constant_override("shadow_offset_x",shadow_offset_x)
var release_visible:bool:
	set(value):
		release_visible=value
		if !Global.in_editor:
			visible=release_visible
			
var shadow_offset_y: int:
	set(value):
		shadow_offset_y = value
		if label!=null:
			label.add_theme_constant_override("shadow_offset_y",shadow_offset_y)
var line_spacing: int:
	set(value):
		line_spacing = value
		if label!=null:
			label.add_theme_constant_override("line_spacing",line_spacing)
var outline_size: int:
	set(value):
		outline_size = value
		if label!=null:
			label.add_theme_constant_override("outline_size",outline_size)
var shadow_outline_size: int:
	set(value):
		shadow_outline_size = value
		if label!=null:
			label.add_theme_constant_override("shadow_outline_size",shadow_outline_size)
var paragraph_spacing: int:
	set(value):
		paragraph_spacing = value
		if label!=null:
			label.add_theme_constant_override("paragraph_spacing",paragraph_spacing)
#endregion
