extends Panel

var obstructive_lenght:=0.0:
	set(value):
		obstructive_lenght=value
		$Panel.size.x=size.x*obstructive_lenght
		$Panel.position.x=(size.x-$Panel.size.x)/2.0
var to_show:=false
func _process(delta: float) -> void:
	if to_show&&obstructive_lenght!=1.0:
		obstructive_lenght=minf(1.0,obstructive_lenght+delta*3.0)
	elif !to_show:
		if obstructive_lenght!=0.0:
			obstructive_lenght=maxf(0.0,obstructive_lenght-delta*3.0)
		else:
			set_process(false)
			$Panel.hide()
func _on_line_edit_mouse_exited() -> void:
	to_show=false
func _on_line_edit_mouse_entered() -> void:
	to_show=true
	$Panel.show()
	set_process(true)
func _ready() -> void:
	pivot_offset=size/2
func merge_and_sort(arr1: Array, arr2: Array) -> Array:
	var merged_array = arr1.duplicate() + arr2.duplicate()
	var result = []
	var index_map = {}
	for item in merged_array:
		var current_index = item["index"]
		var current_score = item["score"]
		if not index_map.has(current_index) or current_score > index_map[current_index]["score"]:
			index_map[current_index] = item
	result = index_map.values()
	result.sort_custom(Callable(self, "_sort_by_score_desc"))
	return result
func _sort_by_score_desc(a, b) -> bool:
	return a["score"] > b["score"]
func _on_line_edit_text_submitted(new_text:  String) -> void:
	$"../..".dataup_current_music_path_list()
	if new_text=="":
		return
	var searcher:=FuzzySearchOptimal.new()
	var name_items_to_search:PackedStringArray
	var singer_items_to_search:PackedStringArray
	for i in $"../MusicList/ScrollContainer/VBoxContainer".get_children():
		if !i.is_queued_for_deletion():
			name_items_to_search.append(i.get_node("TextureRect/ColorRect/Name").text)
			singer_items_to_search.append(i.get_node("TextureRect/ColorRect/Name/Singer").text)
	var results:=merge_and_sort(searcher.search(name_items_to_search,new_text, 0.23),searcher.search(singer_items_to_search,new_text, 0.23))
	var list:PackedStringArray
	if results.is_empty():
		Global.show_hint("没有找到相关内容")
		return
	$LineEdit.text=""
	for i in results:
		list.append(
			$"../MusicList/ScrollContainer/VBoxContainer".get_child(i["index"]).path
		)

	$"../..".dataup_current_music_path_list(list)



func _on_add_mouse_entered() -> void:
	Global.show_tooltips("添加音乐")


func _on_add_mouse_exited() -> void:
	Global.hide_tooltips()
