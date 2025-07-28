extends Element
class_name AudioVisualizationLinear
var points:Array
func _init() -> void:
	class_name_str="AudioVisualizationLinear"
	can_set_property_names={
		"position":["Vector2","位置"],
		"track_mode":["int","形状轨迹的模式\n0:使用多个点来组成线段\n1:用bsaier曲线来组成线段"],
		"frequency_min":["int","最小捕捉频率Hz",0],
		"frequency_max":["int","最大捕捉频率Hz",10000],
		"hight_linear":["float","高度线性值",6000.0],
		"line_density":["float","线条密度值",15.0],
		"line_width":["float","如果主体部分有关于线的地方,线的宽度",6],
		"main_pattern_0_align_center":["bool","主体部分的模式(main_pattern)为0(为垂直与轨迹的线条)时线条的对齐方式\n如果为True,则为中心对齐,否则为底部对其"],
		"main_pattern":["int","主体部分的模式\n0:垂直与轨迹的线条\n1:折线\n2:曲线"],
		"main_pattern_2_smoothness":["float","主体部分的模式(main_pattern)为2(为曲线)时线条的平滑度"],
		"vertical_shift":["float","主体部分相对于轨迹垂直方向的偏移",10.0],
		"response_slow_weight":["float","响应缓慢权重，数值越大，显示的变化越慢，更依赖上一帧，范围0.0~1.0",0.9],
		"inter_sampling_frame_interval":["int","采样的间隔帧数,值越大变化越慢,但可以减轻压力,同时使颤音抖动不明显",0]
	}
	
	
	
	
func get_point_information_by_id(id: int) -> Dictionary:
	if points.size() >=1&&line_density>=1:
		if track_mode==0:
			var accumulated := 0.0
			var target_length := id * line_density
			var perpendicular_radian := 0.0
			for i in points.size():
				if i==points.size()-1:
					break
				var current_point = points[i]
				var next_point = points[i + 1]
				var segment_length = (next_point - current_point).length()
				if accumulated + segment_length > target_length:
					var remaining = target_length - accumulated
					var ratio = remaining / segment_length
					var pos = current_point + (next_point - current_point) * ratio
					perpendicular_radian = (next_point - current_point).angle()
					return {
						"position": pos,
						"perpendicular_radian": perpendicular_radian,
						"is_valid": true
					}
				accumulated += segment_length
		elif track_mode==1:
			var target_length := id * line_density
			if target_length<=$Path2D.curve.get_baked_length():
				var transform = $Path2D.curve.sample_baked_with_rotation(target_length)
				var direction_radian:float
				if id==0:
					direction_radian=$Path2D.curve.sample_baked_with_rotation(id * line_density+line_density).get_rotation()
				else:
					direction_radian = transform.get_rotation()
				return {
					"position": transform.origin,
					"perpendicular_radian": direction_radian,
					"is_valid": true
				}
	return {
		"position": Vector2.ZERO,
		"perpendicular_radian": 0.0,
		"is_valid": false
	}
func _ready() -> void:
	super._ready()
	if !Global.in_editor:
		$Line2D.hide()
		$Points.hide()
		$Line2D2.hide()
		$main_pattern_1/Line2D.hide()
		$main_pattern_2/Line2D.hide()
	bus_effect_instance=AudioServer.get_bus_effect_instance(1,0)
	_update_from_point_nodes()
#region realize function
var bus_effect_instance:AudioEffectSpectrumAnalyzerInstance
func _physics_process(delta: float) -> void:
	if inter_sampling_frame_interval==0||Engine.get_process_frames()%inter_sampling_frame_interval==0:
		var v:Vector2
		if main_pattern==0:
				var count:=$main_pattern_0.get_child_count()
				if count!=0:
					if $main_pattern_0.points.size()==count:
						var node:=$main_pattern_0.get_children()
						var sampling_density:=float(frequency_max-frequency_min)/count
						for i in count:
							v=bus_effect_instance.get_magnitude_for_frequency_range(frequency_min+i*sampling_density,frequency_min+i*sampling_density+sampling_density)
							var base_height = min(max((v.x + v.y) * 0.5 * hight_linear, 6), 1000)
							var height = base_height*(1.0-response_slow_weight) + node[i].mesh.height*response_slow_weight
							if i != 0 && i != count - 1:
								var prev_height = (base_height + node[i-1].mesh.height) * 0.5
								var next_height = (base_height + node[i+1].mesh.height) * 0.5
								height = height * 0.75 + prev_height * 0.125 + next_height * 0.125
							node[i].mesh.height = min(max(height,6),1000)
							
							if !main_pattern_0_align_center:
								node[i].position = $main_pattern_0.points[i] + Vector2.UP.rotated(node[i].rotation) * (height/2.0+vertical_shift)
							else:
								node[i].position = $main_pattern_0.points[i] + Vector2.UP.rotated(node[i].rotation) * (vertical_shift)
				else:
					$main_pattern_0.regenerate()
		elif main_pattern==1:
			var line:=$main_pattern_1/Line2D
			var arr:PackedVector2Array=$main_pattern_1.points.duplicate()
			var count:=arr.size()
			var new_heights:Array[float]
			if $main_pattern_1.points.size()!=0:
				var sampling_density:=float(frequency_max-frequency_min)/count
				for i in count:
					v=bus_effect_instance.get_magnitude_for_frequency_range(frequency_min+i*sampling_density,frequency_min+i*sampling_density+sampling_density)
					var base_height = min(max((v.x + v.y) * 0.5 * hight_linear, 6), 1000)
					var height = base_height*(1.0-response_slow_weight) +$main_pattern_1.heights[i]*response_slow_weight
					if i != 0 && i != count - 1:
						var prev_height = (base_height + $main_pattern_1.heights[i-1]) * 0.5
						var next_height = (base_height +$main_pattern_1.heights[i+1]) * 0.5
						height = height * 0.75 + prev_height * 0.125 + next_height * 0.125
					new_heights.append(height)
					arr[i] = $main_pattern_1.points[i] + Vector2.UP.rotated($main_pattern_1.angle[i])*(height+vertical_shift)
				line.points=arr
				$main_pattern_1.heights=new_heights
			else:
				$main_pattern_1.regenerate()
		elif main_pattern == 2:
			var line: Path2D = $main_pattern_2/Path2D
			var count: int = $main_pattern_2.points.size()
			var new_heights: Array[float]
			var curve_points:=PackedVector2Array()
			
			if count > 0:
				line.curve.clear_points()
				var sampling_density := float(frequency_max - frequency_min) / count
				
				# 第一步：生成曲线点（保持原有逻辑）
				for i in count:
					v = bus_effect_instance.get_magnitude_for_frequency_range(
						frequency_min + i * sampling_density,
						frequency_min + i * sampling_density + sampling_density
					)
					var base_height = min(max((v.x + v.y) * 0.5 * hight_linear, 6), 1000)
					var height = base_height * (1.0 - response_slow_weight) + $main_pattern_2.heights[i] * response_slow_weight
					
					if i != 0 && i != count - 1:
						var prev_height = (base_height + $main_pattern_2.heights[i-1]) * 0.5
						var next_height = (base_height + $main_pattern_2.heights[i+1]) * 0.5
						height = height * 0.75 + prev_height * 0.125 + next_height * 0.125
						
					new_heights.append(height)
					curve_points.append($main_pattern_2.points[i] + Vector2.UP.rotated($main_pattern_2.angle[i]) * (new_heights[i] + vertical_shift))
				
				# 第二步：调用封装函数生成所有点的in/out向量对
				var tangent_pairs = generate_smooth_tangents(curve_points, main_pattern_2_smoothness)
				
				# 第三步：添加点并应用切线（替代原有冗长的条件判断）
				for i in count:
					var current = curve_points[i]
					line.curve.add_point(current)
					
					# 直接从函数返回结果中获取计算好的in/out向量
					var in_vec = tangent_pairs[i][0]
					var out_vec = tangent_pairs[i][1]
					
					line.curve.set_point_in(i, in_vec)
					line.curve.set_point_out(i, out_vec)
				
				$main_pattern_2.heights = new_heights
				$main_pattern_2.update_line()
			else:
				$main_pattern_2.regenerate()
func generate_smooth_tangents(points_arr:PackedVector2Array,smoothness: float) -> Array[Array]:
	var count := points_arr.size()
	var tangent_pairs: Array[Array] = []
	for i in count:
		var current = points_arr[i]
		var prev_dist: float = 0.0
		if i > 0:
			prev_dist = current.distance_to(points_arr[i-1])
		
		var next_dist: float = 0.0
		if i < count - 1:
			next_dist = points_arr[i+1].distance_to(current)
		
		var avg_dist: float = (prev_dist + next_dist) / 2.0
		var tangent_length: float = max(5.0, avg_dist * 0.3)
		
		var in_vec: Vector2 = Vector2.ZERO
		var out_vec: Vector2 = Vector2.ZERO
		
		# 自动计算当前点的基础角度
		var base_angle: float = 0.0
		if count > 1:
			if i == 0:
				# 第一个点：使用与下一个点的连线角度
				base_angle = (points_arr[i+1] - current).angle()
			elif i == count - 1:
				# 最后一个点：使用与上一个点的连线角度
				base_angle = (current - points_arr[i-1]).angle()
			else:
				# 中间点：使用前后点连线的平均角度
				base_angle = ((points_arr[i+1] - current).angle() + (current - points_arr[i-1]).angle()) / 2.0
		
		if count == 1:
			# 单个点的处理（使用默认角度）
			in_vec = Vector2(-tangent_length, 0).rotated(base_angle)
			out_vec = Vector2(tangent_length, 0).rotated(base_angle)
			
		elif i == 0:
			# 第一个点的处理
			var p1 = points_arr[i+1]
			var p2: Vector2
			if count > 2:
				p2 = points_arr[i+2]
			else:
				p2 = p1 + (p1 - current)
			
			var dir1 = (p1 - current).normalized()
			var dir2 = (p2 - p1).normalized()
			var out_dir = (dir1 * 2 + dir2).normalized()
			
			out_vec = out_dir * tangent_length
			in_vec = -out_dir * tangent_length * 0.3
			
		elif i == count - 1:
			# 最后一个点的处理
			var p_1 = points_arr[i-1]
			var p_2: Vector2
			if i > 1:
				p_2 = points_arr[i-2]
			else:
				p_2 = p_1 + (p_1 - current)
			var dir1 = (current - p_1).normalized()
			var dir2 = (p_1 - p_2).normalized()
			var in_dir = (dir1 * 2 + dir2).normalized()
			
			in_vec = -in_dir * tangent_length
			out_vec = in_dir * tangent_length * 0.3
			
		else:
			# 中间点的处理
			var p_prev = points_arr[i-1]
			var p_next = points_arr[i+1]
			
			var prev_dir = (current - p_prev).normalized()
			var next_dir = (p_next - current).normalized()
			var prev_prev_dir: Vector2
			if i > 1:
				prev_prev_dir = (p_prev - points_arr[i-2]).normalized()
			else:
				prev_prev_dir = Vector2.ZERO
			var next_next_dir: Vector2
			if i < count - 2:
				next_next_dir = (points_arr[i+2] - p_next).normalized()
			else:
				next_next_dir = Vector2.ZERO
			
			# 应用平滑度因子计算方向
			var tension_influence = smoothness * 0.5
			var main_dir = (prev_dir + next_dir).normalized()
			var weighted_dir = (
				main_dir * (1 - tension_influence) +
				prev_dir * tension_influence * 0.5 +
				next_dir * tension_influence * 0.5
			).normalized()
			
			var final_dir = (
				weighted_dir * 0.6 +
				prev_prev_dir * 0.1 +
				next_next_dir * 0.1 +
				(prev_dir + next_dir) * 0.2
			).normalized()
			
			# 动态调整切线长度
			var angle_diff = prev_dir.angle_to(next_dir)
			var adj_length = tangent_length * (1 - min(0.6, abs(angle_diff) * 0.2 * (1 + smoothness)))
			
			in_vec = -final_dir * adj_length
			out_vec = final_dir * adj_length
		
		tangent_pairs.append([in_vec, out_vec])
	
	return tangent_pairs
	
	
func _input(event: InputEvent) -> void:
	if Global.in_editor&&Global.mouse_is_in_main_scene()&&Global.main_node.tool_bar.current_index==0&&Global.main_node.current_element==self:
		if event is InputEventMouseButton:
			if Input.is_action_just_pressed("mouse_middle"):
				var point=get_local_mouse_position()+Vector2(5,5)
				points.push_back(point)
				_add_point(point-Vector2(5,5))
				update_lines()
func _add_point(pos:Vector2)->void:
	var point_node:=preload("res://scene/elements/条形音频可视化/point.tscn").instantiate()
	point_node.position=pos
	$Points.add_child(point_node)
func update_lines()->void:
	if Global.in_editor:
		$Line2D.show()
	$Line2D2.hide()
	if track_mode==1:
		$Path2D.curve.clear_points()
		var in_out_arr:=generate_smooth_tangents(points,0.0)
		for i in points.size():
			$Path2D.curve.add_point(points[i],in_out_arr[i][0],in_out_arr[i][1])
		$Line2D2.points=$Path2D.curve.tessellate()
		$Line2D.hide()
		if Global.in_editor:
			$Line2D2.show()
	$Line2D.points=points
	var node=get_node_or_null("main_pattern_"+str(main_pattern))
	if node!=null:
		node.regenerate()
	
func _update_from_point_nodes()->void:
	
	points=$Line2D.points
	#get_node("main_pattern_"+str(main_pattern)).regenerate()
#endregion






#region property
var track_mode:int:
	set(value):
		track_mode=value
		if line_density!=null:
			update_lines()
var frequency_min:int:
	set(value):
		frequency_min=value
var hight_linear:float:
	set(value):
		hight_linear=value
var line_density:float:
	set(value):
		line_density=value
		var node=get_node_or_null("main_pattern_"+str(main_pattern))
		if node!=null:
			node.regenerate()
var inter_sampling_frame_interval:int:
	set(value):
		inter_sampling_frame_interval=value
var vertical_shift:float:
	set(value):
		vertical_shift=value
var main_pattern_0_align_center:float:
	set(value):
		main_pattern_0_align_center=value
var main_pattern_2_smoothness:float:
	set(value):
		main_pattern_2_smoothness=value
var response_slow_weight:float:
	set(value):
		response_slow_weight=value
var frequency_max:int:
	set(value):
		frequency_max=value
var line_width:int:
	set(value):
		line_width=value
		if main_pattern==0:
			$main_pattern_0.width=value
		elif main_pattern==1:
			$main_pattern_1/Line2D.width=value
		elif main_pattern==2:
			$main_pattern_2/Line2D.width=value
var main_pattern:int:
	set(value):
		main_pattern=value
		if value==0:
			$main_pattern_0.visible=true
			$main_pattern_2.visible=false
			$main_pattern_1.visible=false
		elif value==1:
			$main_pattern_0.visible=false
			$main_pattern_1.visible=true
			$main_pattern_2.visible=false
		elif value==2:
			$main_pattern_0.visible=false
			$main_pattern_1.visible=false
			$main_pattern_2.visible=true
#endregion
