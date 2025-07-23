extends Object

class_name FuzzySearchOptimal

# 搜索配置参数
const MAX_RECURSION_DEPTH = 100  # 最大递归深度
const POSITION_WEIGHT = 0.8      # 位置权重系数
const CONTINUITY_BONUS = 1.5     # 连续匹配奖励
const GAP_PENALTY = -0.3         # 间隔惩罚
const MISMATCH_PENALTY = -0.5    # 不匹配惩罚
const CASE_MISMATCH_PENALTY = -0.2  # 大小写不匹配惩罚

# 修改后的搜索函数 - 返回索引和分数
func search(items: Array, query: String, min_score: float = 0.6) -> Array:
	var results = []
	var query_lower = query.to_lower()
	
	for i in range(items.size()):
		var score = evaluate_match(items[i], query_lower)
		if score >= min_score:
			results.append({"index": i, "score": score})
	
	# 按分数排序（降序）
	results.sort_custom(Callable(self, "_sort_by_score_desc"))
	return results

# 评估匹配分数（核心算法）
func evaluate_match(item: String, query: String) -> float:
	var item_lower = item.to_lower()
	var item_len = item_lower.length()
	var query_len = query.length()
	
	if query_len == 0:
		return 0.0
	
	# 创建得分矩阵和回溯矩阵
	var score_matrix = []
	var trace_matrix = []
	
	# 初始化矩阵
	for i in range(item_len + 1):
		score_matrix.append([])
		trace_matrix.append([])
		for j in range(query_len + 1):
			score_matrix[i].append(0.0)
			trace_matrix[i].append(0)  # 0: 无路径, 1: 左上, 2: 上, 3: 左
	
	# 填充矩阵（全局序列比对）
	for i in range(1, item_len + 1):
		for j in range(1, query_len + 1):
			var match_score = calculate_match_score(item_lower[i-1], query[j-1], i-1, j-1, query_len)
			
			# 计算三种可能的得分
			var diagonal_score = score_matrix[i-1][j-1] + match_score
			var up_score = score_matrix[i-1][j] + GAP_PENALTY
			var left_score = score_matrix[i][j-1] + GAP_PENALTY
			
			# 选择最高得分
			var max_score = max(diagonal_score, up_score, left_score)
			score_matrix[i][j] = max_score
			
			# 记录回溯路径
			if max_score == diagonal_score:
				trace_matrix[i][j] = 1
			elif max_score == up_score:
				trace_matrix[i][j] = 2
			else:
				trace_matrix[i][j] = 3
	
	# 回溯以找到最佳路径
	var matches = backtrack(trace_matrix, item_len, query_len)
	
	# 计算最终得分（归一化）
	var final_score = calculate_final_score(matches, item_len, query_len)
	return final_score

# 计算字符匹配得分（考虑位置权重和连续匹配）
func calculate_match_score(item_char: String, query_char: String, item_pos: int, query_pos: int, query_length: int) -> float:
	# 基础匹配得分
	if item_char == query_char:
		var score = 1.0
		
		# 大小写匹配奖励
		if item_char == item_char.to_upper() and query_char == query_char.to_upper():
			score += 0.1
		
		# 位置权重（查询词前面的字符更重要）
		score *= 1.0 + (1.0 - query_pos / float(query_length - 1)) * POSITION_WEIGHT
		
		return score
	else:
		return MISMATCH_PENALTY

# 回溯函数
func backtrack(trace_matrix: Array, i: int, j: int) -> Array:
	var matches = []
	var recursion_depth = 0
	
	while i > 0 and j > 0 and recursion_depth < MAX_RECURSION_DEPTH:
		var direction = trace_matrix[i][j]
		
		if direction == 1:  # 左上（匹配或不匹配）
			matches.append({"item_pos": i-1, "query_pos": j-1})
			i -= 1
			j -= 1
		elif direction == 2:  # 上（间隙）
			i -= 1
		elif direction == 3:  # 左（间隙）
			j -= 1
		
		recursion_depth += 1
	
	# 反转以保持正确的顺序
	matches.reverse()
	return matches

# 计算最终得分
func calculate_final_score(matches: Array, item_len: int, query_len: int) -> float:
	if matches.size() == 0:
		return 0.0
	
	# 计算连续匹配奖励
	var continuity_bonus = 0.0
	var current_run = 1
	
	for i in range(1, matches.size()):
		if matches[i]["item_pos"] == matches[i-1]["item_pos"] + 1 and matches[i]["query_pos"] == matches[i-1]["query_pos"] + 1:
			current_run += 1
		else:
			if current_run > 1:
				continuity_bonus += pow(current_run, 1.2) * CONTINUITY_BONUS
			current_run = 1
	
	# 添加最后一个连续段的奖励
	if current_run > 1:
		continuity_bonus += pow(current_run, 1.2) * CONTINUITY_BONUS
	
	# 计算覆盖率得分（匹配字符数/查询长度）
	var coverage = matches.size() / float(query_len)
	
	# 计算位置惩罚（匹配越分散，惩罚越大）
	var position_penalty = 0.0
	if matches.size() > 1:
		for i in range(1, matches.size()):
			var gap = matches[i]["item_pos"] - matches[i-1]["item_pos"] - 1
			if gap > 0:
				position_penalty += gap * GAP_PENALTY
	
	# 综合得分（匹配质量 + 连续性奖励 + 位置惩罚）
	var base_score = matches.size() / float(max(item_len, query_len))
	var final_score = base_score + (continuity_bonus / float(item_len)) + (position_penalty / float(item_len))
	
	# 归一化到0-1范围
	final_score = clamp(final_score, 0.0, 1.0)
	return final_score

# 辅助函数：按分数降序排序
func _sort_by_score_desc(a, b) -> bool:
	return a.score > b.score
