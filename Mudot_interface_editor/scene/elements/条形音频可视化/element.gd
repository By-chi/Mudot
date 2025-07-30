extends Element
class_name AudioVisualizationLinear
var points:PackedVector2Array:
	set(value):
		points=value
		invalidate_cache()
var curve_closed:=false
func _init() -> void:
	class_name_str="AudioVisualizationLinear"
	can_set_property_names = {
		"track_mode": ["int", "形状轨迹的模式\n0:使用多个点来组成线段\n1:用bsaier曲线来组成线段\n2:用多个点求质心的方法来绘制一个椭圆轨迹"],
		"track_mode_2_density": ["float", "形状轨迹的模式(track_mode)为2(用多个点求质心的方法来绘制一个椭圆轨迹)的采样密度\n越小越密", 20.0],
		"track_closed": ["bool", "如果为 true 并且形状轨迹的折线有超过2个点，则最后一个点和第一个点将通过线段连接"],
		"line_density": ["float", "线条密度值", 15.0],
		"line_width": ["float", "如果主体部分有关于线的地方,线的宽度", 6],
		"position": ["Vector2", "位置"],
		"rotation": ["float", "旋转(角度)"],

		"main_pattern": ["int", "主体部分的模式\n0:垂直与轨迹的线条\n1:折线\n2:曲线"],
		"main_pattern_0_align_center": ["bool", "主体部分的模式(main_pattern)为0(为垂直与轨迹的线条)时线条的对齐方式\n如果为True,则为中心对齐,否则为底部对其"],
		"main_pattern_2_smoothness": ["float", "主体部分的模式(main_pattern)为2(为曲线)时线条的平滑度"],
		"vertical_shift": ["float", "主体部分相对于轨迹垂直方向的偏移", 10.0],
		"vertical_summetry": ["bool", "如果为True,则主体部分垂直镜像,这在一些封闭图形中很有用"],

		"frequency_min": ["int", "最小捕捉频率Hz", 0],
		"frequency_max": ["int", "最大捕捉频率Hz", 10000],
		"hight_linear": ["float", "高度线性值", 6000.0],
		"offset": ["float", "偏移量"],
		"response_slow_weight": ["float", "响应缓慢权重，数值越大，显示的变化越慢，更依赖上一帧，范围0.0~1.0", 0.9],
		"inter_sampling_frame_interval": ["int", "采样的间隔帧数,值越大变化越慢,但可以减轻压力,同时使颤音抖动不明显", 0],
		"viscosity_weight": ["float", "粘度权重，数值越大，越依赖左右的采样点值，范围0.0~1.0", 0.25]
	}
#region get_id
# 建议在类中添加这些缓存变量
var _cached_total_length: float = -1.0
var _cached_curve_length: float = -1.0
var _cached_arr: PackedVector2Array = PackedVector2Array()
var _cache_valid: bool = false

func get_point_information_by_id(id: int) -> Dictionary:
	# 提前检查基本条件
	if points.size() < 1 or line_density < 1:
		return {
			"position": Vector2.ZERO,
			"perpendicular_radian": 0.0,
			"is_valid": false
		}
	
	# 缓存失效时才更新缓存数据
	if not _cache_valid:
		update_cache()
	
	var modulus_offset_value: float
	var target_length: float
	
	match track_mode:
		0, 2:
			# 使用缓存的总长度
			modulus_offset_value = fmod(offset, _cached_total_length)
			var raw_length := id * line_density
			target_length = raw_length + modulus_offset_value
			
			# 检查是否超出范围
			if target_length >= _cached_total_length + modulus_offset_value:
				return {
					"position": Vector2.ZERO,
					"perpendicular_radian": 0.0,
					"is_valid": false
				}
			
			# 处理循环偏移
			if target_length >= _cached_total_length:
				target_length -= _cached_total_length
			
			# 路径采样（使用缓存的数组）
			var accumulated: float = 0.0
			var arr_size: int = _cached_arr.size()
			
			for i in arr_size-1:
				var current_point: Vector2 = _cached_arr[i]
				var next_point: Vector2 = _cached_arr[i+1]
				var segment_length: float = (next_point - current_point).length()
				
				if accumulated + segment_length > target_length:
					var remaining: float = target_length - accumulated
					var ratio: float = remaining / segment_length
					var pos: Vector2 = current_point + (next_point - current_point) * ratio
					var radian: float = (next_point - current_point).angle()
					
					return {
						"position": pos,
						"perpendicular_radian": radian,
						"is_valid": true
					}
				
				accumulated += segment_length
		
		1:
			# 使用缓存的曲线长度
			modulus_offset_value = fmod(offset, _cached_curve_length)
			var raw_length := id * line_density
			target_length = raw_length + modulus_offset_value
			
			if target_length >= _cached_curve_length + modulus_offset_value:
				return {
					"position": Vector2.ZERO,
					"perpendicular_radian": 0.0,
					"is_valid": false
				}
			
			if target_length >= _cached_curve_length:
				target_length -= _cached_curve_length
			
			# 曲线采样
			var transform: Transform2D = $Path2D.curve.sample_baked_with_rotation(target_length)
			var direction_radian: float
			
			if id == 0:
				direction_radian = $Path2D.curve.sample_baked_with_rotation(
					target_length + line_density
				).get_rotation()
			else:
				direction_radian = transform.get_rotation()
			
			return {
				"position": transform.origin,
								"perpendicular_radian": direction_radian,
				"is_valid": true
			}

	# 如果循环结束仍未找到（理论上不应发生）
	return {
		"position": Vector2.ZERO,
		"perpendicular_radian": 0.0,
		"is_valid": false
	}

# 新增缓存更新函数
func update_cache() -> void:
	# 更新路径数组缓存
	if track_mode != 2:
		_cached_arr = points.duplicate()
	else:
		_cached_arr = $Line2D2.points.duplicate()
	
	# 处理闭合路径
	if track_closed and _cached_arr.size() > 0:
		_cached_arr.append(_cached_arr[0])
	
	# 更新长度缓存
	match track_mode:
		0, 2:
			# 预计算总长度
			_cached_total_length = 0.0
			for i in _cached_arr.size()-1:
				_cached_total_length += (_cached_arr[i+1] - _cached_arr[i]).length()
		1:
			# 缓存曲线长度
			_cached_curve_length = $Path2D.curve.get_baked_length()
	
	_cache_valid = true

# 当路径数据发生变化时调用此函数
func invalidate_cache() -> void:
	_cache_valid = false
#endregion
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
	offset+=delta*10.0
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
							height = height * (1.0-viscosity_weight) +( prev_height  + next_height) * viscosity_weight
						if vertical_summetry:
							height=-height
						node[i].mesh.height = min(max(absf(height),6),1000)
						if !main_pattern_0_align_center:
							node[i].position = $main_pattern_0.points[i] + Vector2.UP.rotated(node[i].rotation) * (height/2.0+vertical_shift)
						else:
							node[i].position = $main_pattern_0.points[i] - Vector2.UP.rotated(node[i].rotation) * (vertical_shift)
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
						height = height * (1.0-viscosity_weight) +( prev_height  + next_height) * viscosity_weight
					if vertical_summetry:
						height=-height
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
						if vertical_summetry:
							prev_height=-prev_height
							next_height=-next_height
						height = height * (1.0-viscosity_weight) +( prev_height  + next_height) * viscosity_weight
					height = abs(height)
					if vertical_summetry:
						height = -height
					#print(height)
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
		var base_angle: float = 0.0
		if count > 1:
			if i == 0:
				base_angle = (points_arr[i+1] - current).angle()
			elif i == count - 1:
				base_angle = (current - points_arr[i-1]).angle()
			else:
				base_angle = ((points_arr[i+1] - current).angle() + (current - points_arr[i-1]).angle()) / 2.0
		if count == 1:
			in_vec = Vector2(-tangent_length, 0).rotated(base_angle)
			out_vec = Vector2(tangent_length, 0).rotated(base_angle)
		elif i == 0:
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
			var angle_diff = prev_dir.angle_to(next_dir)
			var adj_length = tangent_length * (1 - min(0.6, abs(angle_diff) * 0.2 * (1 + smoothness)))
			in_vec = -final_dir * adj_length
			out_vec = final_dir * adj_length
		tangent_pairs.append([in_vec, out_vec])
	return tangent_pairs
func _input(event: InputEvent) -> void:
	if Global.in_editor&&Global.main_node.tool_bar.current_index==0&&Global.main_node.current_element==self:
		if event is InputEventMouseButton:
			if Input.is_action_just_pressed("mouse_middle"):
				var point=get_local_mouse_position()+Vector2(8,8)
				points.push_back(point)
				_add_point(point-Vector2(8,8))
				update_lines()
func _add_point(pos:Vector2)->void:
	var point_node:=preload("res://scene/elements/条形音频可视化/point.tscn").instantiate()
	point_node.position=pos
	$Points.add_child(point_node)
func update_lines()->void:
	if Global.in_editor:
		$Line2D.show()
	$Line2D2.hide()
	if track_mode!=2:
		var arr:=PackedVector2Array()
		arr=points.duplicate()
		if curve_closed:
			arr.append(points[0])
		if track_mode==1:
			$Path2D.curve.clear_points()
			var in_out_arr:=generate_smooth_tangents(arr,0.0)
			for i in arr.size():
				$Path2D.curve.add_point(arr[i],in_out_arr[i][0],in_out_arr[i][1])
			$Line2D2.points=$Path2D.curve.tessellate()
			$Line2D.hide()
			if Global.in_editor:
				$Line2D2.show()
		$Line2D.points=points
		var node=get_node_or_null("main_pattern_"+str(main_pattern))
		if node!=null:
			node.regenerate()
	elif points.size()>=2:
		$Line2D2.points=get_easy_ellipse_points(points)
		if Global.in_editor:
			$Line2D2.show()
		$Line2D.points=points
		var node=get_node_or_null("main_pattern_"+str(main_pattern))
		if node!=null:
			node.regenerate()
#region mode2
func always_fit_ellipse(arr: Array) -> Dictionary:
	if arr.is_empty():
		push_error("输入点不能为空")
		return {}
	var center = Vector2.ZERO
	for p in arr:
		center += p
	center /= arr.size()
	var Sxx = 0.0
	var Sxy = 0.0
	var Syy = 0.0
	for p in arr:
		var d = p - center
		Sxx += d.x * d.x
		Sxy += d.x * d.y
		Syy += d.y * d.y
	Sxx /= arr.size()
	Sxy /= arr.size()
	Syy /= arr.size()
	var T = Sxx + Syy
	var D = Sxx * Syy - Sxy * Sxy
	var tmp = sqrt(max(0.0, (T * T) / 4.0 - D))
	var lambda1 = T / 2.0 + tmp
	var main_axis = Vector2(1, 0)
	if abs(Sxy) > 1e-6:
		main_axis = Vector2(lambda1 - Syy, Sxy).normalized()
	var angle = atan2(main_axis.y, main_axis.x)
	var a = 0.0
	var b = 0.0
	for p in arr:
		var d = p - center
		var proj_main = abs(d.x * main_axis.x + d.y * main_axis.y)
		var proj_sub = abs(-d.x * main_axis.y + d.y * main_axis.x)
		a = max(a, proj_main)
		b = max(b, proj_sub)
	a += 10.0
	b += 10.0
	return {
		"center": center,
		"a": a,
		"b": b,
		"angle": angle
	}
func sample_ellipse(center: Vector2, a: float, b: float, angle: float) -> Array:
	var h = pow((a - b), 2) / pow((a + b), 2)
	var L = PI * (a + b) * (1 + (3 * h) / (10 + sqrt(4 - 3 * h)))
	var N = int(L / track_mode_2_density)
	N = max(N, 30)
	var arr = []
	for i in range(N):
		var t = TAU * i / N
		var x = a * cos(t)
		var y = b * sin(t)
		var xr = x * cos(angle) - y * sin(angle)
		var yr = x * sin(angle) + y * cos(angle)
		arr.append(center + Vector2(xr, yr))
	if arr.size() > 0:
		arr.append(arr[0])
	return arr
func get_easy_ellipse_points(input_points: Array) -> Array:
	var ellipse = always_fit_ellipse(input_points)
	pivot_offset=ellipse["center"]
	if ellipse.size() == 0:
		push_error("无法拟合椭圆")
		return []
	return sample_ellipse(ellipse["center"], ellipse["a"], ellipse["b"], ellipse["angle"])
#endregion

func _update_from_point_nodes()->void:
	points=$Line2D.points
#endregion
#region property
var track_mode:int:
	set(value):
		track_mode=value
		if line_density!=null:
			update_lines()
var track_mode_2_density:float:
	set(value):
		track_mode_2_density=value
		if line_density!=null:
			update_lines()
var frequency_min:int:
	set(value):
		frequency_min=value
var hight_linear:float:
	set(value):
		hight_linear=value
var vertical_summetry:bool:
	set(value):
		vertical_summetry=value
var viscosity_weight:float:
	set(value):
		viscosity_weight=value
var offset:float:
	set(value):
		offset=value
		if line_density!=null:
			update_lines()
var track_closed:bool:
	set(value):
		track_closed=value
		if track_mode==0||track_mode==2:
			$Line2D.closed=value
			$main_pattern_0.closed=value
		elif track_mode==1:
			curve_closed=value
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
