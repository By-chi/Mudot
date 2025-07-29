extends Node2D
var width:=6.0
var closed:=false
var points: PackedVector2Array = [] :
	get():
		if points==PackedVector2Array():
			regenerate()
		return points
func regenerate() -> void:
	var arr:=PackedVector2Array()
	arr=$"..".points.duplicate()
	if arr.size() == 0:
		return
	if closed:
		arr.append(arr[0])
	var children = get_children()
	var child_index = 0
	var new_points:=PackedVector2Array()
	for i in range(0, 10000):
		var information = $"..".get_point_information_by_id(i)
		if not information["is_valid"]:
			break
		var pos = information["position"]
		new_points.append(pos)
		if child_index < children.size():
			var line_node = children[child_index]
			line_node.position = pos
			line_node.rotation = information["perpendicular_radian"]
		else:
			_add_vertical_lines(pos, information["perpendicular_radian"])
		child_index += 1
	if child_index < children.size():
		for i in range(child_index, children.size()):
			children[i].queue_free()
	points = new_points
func _add_vertical_lines(pos:Vector2,line_rotation:float)->void:
	var node:=MeshInstance2D.new()
	node.mesh=CapsuleMesh.new()
	node.mesh.rings=4
	node.mesh.radius=width/2.0
	node.mesh.height=30
	node.mesh.radial_segments=4
	node.position=pos
	node.rotation=line_rotation
	add_child(node)
