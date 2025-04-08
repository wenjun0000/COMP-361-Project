
extends Node2D



class Segment:
	var start: Vector2
	var end: Vector2

	func _init(_start: Vector2, _end: Vector2):
		start = _start
		end = _end

	func is_vertical() -> bool:
		return is_equal_approx(start.x, end.x)

	func intersects_vertically(x: float) -> Vector2:
		if (start.x - x) * (end.x - x) > 0:
			return Vector2.INF
		if is_equal_approx(start.x, end.x):
			return Vector2.INF
		var t = (x - start.x) / (end.x - start.x)
		return start.lerp(end, t)

class Trapezoid:
	var top: Segment
	var bottom: Segment
	var left: float
	var right: float
	var center: Vector2

	func _init(_top: Segment, _bottom: Segment, _left: float, _right: float):
		top = _top
		bottom = _bottom
		left = _left
		right = _right
		center = (top.start + bottom.end) * 0.5

var segments: Array = []
var trapezoids: Array = []
var nav_data: NavigationSpaceData
var path: Array = []

func _ready():
	nav_data = NavigationSpaceData.new()
	nav_data.fetch_data_from_map(preload("res://map/map01.tscn").instantiate())
	segments = []

	nav_data.boundary_polygon = ensure_ccw(nav_data.boundary_polygon)
	add_poly_segment(nav_data.boundary_polygon)

	for polygon in nav_data.obstacle_polygons:
		polygon = ensure_cw(polygon)
		add_poly_segment(polygon)

	generate_trapezoids()
	compute_path()
	request_draw()

func add_poly_segment(points: PackedVector2Array):
	for i in range(points.size()):
		segments.append(Segment.new(points[i], points[(i + 1) % points.size()]))

func ensure_ccw(polygon: PackedVector2Array) -> PackedVector2Array:
	if Geometry2D.is_polygon_clockwise(polygon):
		polygon.reverse()
	return polygon

func ensure_cw(polygon: PackedVector2Array) -> PackedVector2Array:
	if not Geometry2D.is_polygon_clockwise(polygon):
		polygon.reverse()
	return polygon

func is_point_in_free_space(point: Vector2) -> bool:
	if not Geometry2D.is_point_in_polygon(point, nav_data.boundary_polygon):
		return false
	for obs in nav_data.obstacle_polygons:
		if Geometry2D.is_point_in_polygon(point, obs):
			return false
	return true

func generate_trapezoids():
	trapezoids.clear()
	var vertices := []
	for s in segments:
		vertices.append(s.start)
		vertices.append(s.end)
	vertices.sort_custom(func(a, b): return a.x < b.x)

	for v in vertices:
		var up_point = project_vertical(v, -1)
		var down_point = project_vertical(v, 1)
		if up_point != Vector2.INF:
			var up_mid = (up_point + v) * 0.5
			if is_point_in_free_space(up_mid):
				trapezoids.append(Trapezoid.new(
					Segment.new(up_point, v),
					Segment.new(v, v),
					v.x, v.x
				))
		if down_point != Vector2.INF:
			var down_mid = (v + down_point) * 0.5
			if is_point_in_free_space(down_mid):
				trapezoids.append(Trapezoid.new(
					Segment.new(v, v),
					Segment.new(v, down_point),
					v.x, v.x
				))

func project_vertical(origin: Vector2, direction: int) -> Vector2:
	var min_dist := INF
	var closest_point := Vector2.INF
	for s in segments:
		var intersection = s.intersects_vertically(origin.x)
		if intersection != Vector2.INF:
			if direction < 0 and intersection.y < origin.y:
				var dist = origin.y - intersection.y
				if dist < min_dist:
					min_dist = dist
					closest_point = intersection
			elif direction > 0 and intersection.y > origin.y:
				var dist = intersection.y - origin.y
				if dist < min_dist:
					min_dist = dist
					closest_point = intersection
	return closest_point

func compute_path():
	path.clear()
	if trapezoids.size() == 0:
		return

	# Naive connection based on proximity (build visibility graph)
	var graph = {}
	for t in trapezoids:
		graph[t.center] = []
	for a in trapezoids:
		for b in trapezoids:
			if a == b:
				continue
			if a.center.distance_to(b.center) < 100 and is_path_clear(a.center, b.center):
				graph[a.center].append(b.center)
	# Find start and end trapezoid centers
	var start = find_nearest_center(nav_data.start_point)
	var goal = find_nearest_center(nav_data.end_point)
	path = a_star(graph, start, goal)

func find_nearest_center(point: Vector2) -> Vector2:
	var best := Vector2.INF
	var min_dist := INF
	for t in trapezoids:
		var d = t.center.distance_to(point)
		if d < min_dist:
			min_dist = d
			best = t.center
	return best

func is_path_clear(a: Vector2, b: Vector2) -> bool:
	var midpoint = (a + b) * 0.5
	return is_point_in_free_space(midpoint)

func a_star(graph: Dictionary, start: Vector2, goal: Vector2) -> Array:
	var open_set = [start]
	var came_from = {}
	var g_score = {start: 0.0}
	var f_score = {start: start.distance_to(goal)}

	while open_set.size() > 0:
		open_set.sort_custom(func(a, b): return f_score.get(a, INF) < f_score.get(b, INF))
		var current = open_set[0]
		if current == goal:
			return reconstruct_path(came_from, current)

		open_set.pop_front()
		for neighbor in graph.get(current, []):
			var tentative_g = g_score.get(current, INF) + current.distance_to(neighbor)
			if tentative_g < g_score.get(neighbor, INF):
				came_from[neighbor] = current
				g_score[neighbor] = tentative_g
				f_score[neighbor] = tentative_g + neighbor.distance_to(goal)
				if neighbor not in open_set:
					open_set.append(neighbor)
	return []

func reconstruct_path(came_from: Dictionary, current: Vector2) -> Array:
	var total_path = [current]
	while current in came_from:
		current = came_from[current]
		total_path.prepend(current)
	return total_path

func _draw():
	for s in segments:
		draw_line(s.start, s.end, Color.RED, 2)
	for t in trapezoids:
		draw_line(t.top.start, t.top.end, Color.BLUE, 1)
		draw_line(t.bottom.start, t.bottom.end, Color.BLUE, 1)
		draw_line(t.top.start, t.bottom.start, Color.BLUE, 1)
		draw_line(t.top.end, t.bottom.end, Color.BLUE, 1)
	for i in range(path.size() - 1):
		draw_line(path[i], path[i + 1], Color.GREEN, 2)
	draw_circle(nav_data.start_point, 5, Color.YELLOW)
	draw_circle(nav_data.end_point, 5, Color.CYAN)


func request_draw():
	queue_redraw()
