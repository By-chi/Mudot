extends Node2D
var points: PackedVector2Array = []
var angle:Array[float]=[]
var heights:Array[float]=[]
func regenerate() -> void:
	var parent_points = $"..".points
	if parent_points.size() <2:
		return
	points.clear()
	angle.clear()
	for i in range(0, 10000):
		var information = $"..".get_point_information_by_id(i)
		if not information["is_valid"]:
			break
		var pos = information["position"]
		points.append(pos)
		angle.append(information["perpendicular_radian"])
	heights.clear()
	heights.resize(points.size())
	for i in points.size():
		if heights[i]==null:
			heights[i]=float()
