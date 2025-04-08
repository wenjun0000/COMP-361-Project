extends Node2D

# Define obstacles as arrays of Vector2 points (polygons)
var obstacles = [
	# Quadrilateral
	[Vector2(75, 75), Vector2(200, 100), Vector2(200, 200), Vector2(100, 200)],
	# Triangle
	[Vector2(300, 300), Vector2(400, 350), Vector2(350, 400)],
	# Irregular quadrilateral
	[Vector2(250, 150), Vector2(300, 120), Vector2(350, 150), Vector2(320, 200)],
	# Triangle
	[Vector2(150, 300), Vector2(200, 350), Vector2(150, 400)],
	# Another irregular quadrilateral
	[Vector2(400, 100), Vector2(450, 120), Vector2(430, 180), Vector2(380, 160)]
]

# Start and goal positions for path planning
var start_point = Vector2(50, 50)
var goal_point = Vector2(450, 450)

# These arrays will hold all vertices (start, goal, and polygon corners) and graph edges.
var vertices = []
var edges = {}  # Dictionary: key = vertex index, value = array of [neighbor index, cost]
var path = []   # Shortest path from start to goal (computed with Dijkstra)

func _ready():
	# Build the vertex list: start and goal first, then each obstacle vertex.
	vertices = []
	vertices.append(start_point)  # index 0: start
	vertices.append(goal_point)   # index 1: goal
	for poly in obstacles:
		for point in poly:
			vertices.append(point)
	
	# Build the visibility graph based on free line-of-sight between vertices.
	build_visibility_graph()
	
	# Compute the shortest path from start (index 0) to goal (index 1)
	path = dijkstra(0, 1)
	
	# Request a redraw to display the obstacles, graph, and path.
	queue_redraw()

# Constructs the visibility graph by checking line-of-sight between each pair of vertices.
func build_visibility_graph():
	edges.clear()
	# Initialize an empty list for each vertex.
	for i in range(vertices.size()):
		edges[i] = []
	
	# Check each pair (i, j) for visibility.
	for i in range(vertices.size()):
		for j in range(i + 1, vertices.size()):
			if check_is_visible(vertices[i], vertices[j]):
				var cost = vertices[i].distance_to(vertices[j])
				edges[i].append([j, cost])
				edges[j].append([i, cost])

# Returns true if the line segment between p1 and p2 is unobstructed.
# Also, if both endpoints belong to the same obstacle, the edge is skipped.
func check_is_visible(p1: Vector2, p2: Vector2) -> bool:
	# Skip connection if both points belong to the same obstacle.
	for poly in obstacles:
		if poly.find(p1) != -1 and poly.find(p2) != -1:
			return false

	# Check if the segment intersects any obstacle edge.
	for poly in obstacles:
		for k in range(poly.size()):
			var a = poly[k]
			var b = poly[(k + 1) % poly.size()]
			# Skip intersection test if p1 or p2 is exactly one of the polygon vertices.
			if (p1 == a or p1 == b or p2 == a or p2 == b):
				continue
			if segments_intersect(p1, p2, a, b):
				return false
	return true

# Checks if two line segments (p1-p2 and p3-p4) intersect.
func segments_intersect(p1: Vector2, p2: Vector2, p3: Vector2, p4: Vector2) -> bool:
	var d1 = direction(p3, p4, p1)
	var d2 = direction(p3, p4, p2)
	var d3 = direction(p1, p2, p3)
	var d4 = direction(p1, p2, p4)
	
	if ((d1 > 0 and d2 < 0) or (d1 < 0 and d2 > 0)) and ((d3 > 0 and d4 < 0) or (d3 < 0 and d4 > 0)):
		return true
	return false

# Helper function: computes the cross product (as a scalar) for determining orientation.
func direction(pi: Vector2, pj: Vector2, pk: Vector2) -> float:
	return (pk - pi).cross(pj - pi)

# Simple implementation of Dijkstra's algorithm to compute the shortest path.
func dijkstra(start_index: int, goal_index: int) -> Array:
	var dist = []
	var prev = []
	for i in range(vertices.size()):
		dist.append(1e10)
		prev.append(-1)
	dist[start_index] = 0
	var unvisited = []
	for i in range(vertices.size()):
		unvisited.append(i)
	
	while unvisited.size() > 0:
		# Find the vertex in unvisited with the smallest distance.
		var u = unvisited[0]
		for v in unvisited:
			if dist[v] < dist[u]:
				u = v
		if u == goal_index:
			break
		unvisited.erase(u)
		for edge in edges[u]:
			var v = edge[0]
			var cost = edge[1]
			if v in unvisited and dist[u] + cost < dist[v]:
				dist[v] = dist[u] + cost
				prev[v] = u
	
	# Reconstruct the shortest path from goal to start.
	var result = []
	var u = goal_index
	while u != -1:
		result.insert(0, vertices[u])
		u = prev[u]
	return result

# The _draw() function visualizes the obstacles, visibility graph edges, vertices, and computed path.
func _draw():
	# Draw each obstacle as a filled polygon with an outline.
	for poly in obstacles:
		draw_polygon(poly, [Color(0.5, 0.5, 0.5)])
		draw_polyline(poly + [poly[0]], Color(0, 0, 0), 2)
	
	# Draw the visibility graph edges in green.
	for i in edges.keys():
		for edge in edges[i]:
			var j = edge[0]
			draw_line(vertices[i], vertices[j], Color(0, 1, 0))
	
	# Draw vertices (start, goal, and obstacle corners) as small red circles.
	for v in vertices:
		draw_circle(v, 5, Color(1, 0, 0))
	
	# If a path was found, draw it in blue.
	if path.size() > 1:
		for i in range(path.size() - 1):
			draw_line(path[i], path[i + 1], Color(0, 0, 1), 3)
