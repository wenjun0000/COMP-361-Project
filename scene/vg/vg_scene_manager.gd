extends Node2D


@export var hover_target_distance: float = 20.0

enum Phase {PHASE1, PHASE2, PHASE3}
var current_phase = Phase.PHASE1

@onready var phase_1_ui = %Phase1UI
@onready var phase_2_ui = %Phase2UI
@onready var phase_3_ui = %Phase3UI

var map = preload("res://map/map01.tscn").instantiate()
var target_mark = preload("res://UI/mis/target_icon.tscn").instantiate()

var boundary_polygon:PackedVector2Array
var obstacles_polygon:Array[PackedVector2Array]
var start_point:Vector2
var end_point:Vector2

var vertices: PackedVector2Array = []
var edges = {}
var path = []

var highlighted_edges = {}
var highlighted_path = []

var highlighted_vertex_index: int = -1
var selected_vertex_index: int = -1

var edges_finished: int = 0
var edges_to_finish: int = 0


func _ready() -> void:
	add_child(map)
	add_child(target_mark)
	fetch_data()
	build_vertices()
	build_edges()
	edges_to_finish = count_edges(edges)
	build_obstacle_edges()
	path = PathFinding.dijkstra(0, 1, vertices, edges)
	


# Interact
func _input(event: InputEvent) -> void:
	if current_phase != Phase.PHASE1 and event is InputEventMouseMotion:
		highlighted_vertex_index = closest_vertex_to_cursor(event.position)
	if highlighted_vertex_index != -1:
		target_mark.global_position = vertices[highlighted_vertex_index]
		target_mark.show()
	else:
		target_mark.hide()

func _unhandled_input(event: InputEvent) -> void:
	if selected_vertex_index == -1:
		if highlighted_vertex_index != -1:
			if event.is_action_pressed("Left"):
				selected_vertex_index = highlighted_vertex_index
			elif event.is_action_pressed("Right"):
				build_edges_for_vertex(highlighted_vertex_index)
	else:
		if event.is_action_pressed("Left") and highlighted_vertex_index != -1:
			build_single_edge(selected_vertex_index, highlighted_vertex_index)
		if event.is_action_pressed("Right"):
			selected_vertex_index = -1
	
	if edges_finished == edges_to_finish:
		begin_phase_3()
	queue_redraw()

func closest_vertex_to_cursor(mouse_pos: Vector2) -> int:
	for i in vertices.size():
		if mouse_pos.distance_to(vertices[i]) <= hover_target_distance:
			return i
	return -1






# Core
func progress_phase() -> void:
	if current_phase == Phase.PHASE1:
		current_phase = Phase.PHASE2
		phase_1_ui.hide()
		phase_2_ui.show()
		begin_phase_2()
	elif current_phase == Phase.PHASE2:
		current_phase = Phase.PHASE3
		phase_2_ui.hide()
		phase_3_ui.show()
		begin_phase_3()
	elif current_phase == Phase.PHASE3:
		end_all_phase()

func begin_phase_2() -> void:
	pass

func begin_phase_3() -> void:
	highlighted_edges = edges
	queue_redraw()

func end_all_phase() -> void:
	highlighted_path = path
	queue_redraw()

func toggle_obstacles():
	for obstacle in map.find_child('Obstacles').get_children():
		if obstacle.visible:
			obstacle.visible = false
		else:
			obstacle.visible = true

# Function
func fetch_data() -> void:
	boundary_polygon = map.find_child('Boundary').polygon
	for obstacle in map.find_child('Obstacles').get_children():
		obstacles_polygon.append(obstacle.polygon)
	start_point = map.find_child('Start').position
	end_point = map.find_child('End').position

func build_vertices() -> void:
	vertices.append(start_point)
	vertices.append(end_point)
	for polygon in obstacles_polygon:
		for point in polygon:
			vertices.append(point)

func build_edges() -> void:
	for i in range(vertices.size()):
		edges[i] = []
	for i in range(vertices.size()):
		for j in range(i + 1, vertices.size()):
			if is_edge_visible(vertices[i], vertices[j]):
				var cost = vertices[i].distance_to(vertices[j])
				edges[i].append([j, cost])
				edges[j].append([i, cost])

func build_edges_for_vertex(v_idx: int) -> void:
	# Ensure the edges for this vertex start fresh.
	highlighted_edges[v_idx] = []
	# Check connection from this vertex to every other vertex.
	for j in range(vertices.size()):
		if j == v_idx:
			continue
		if is_edge_visible(vertices[v_idx], vertices[j]):
			var cost = vertices[v_idx].distance_to(vertices[j])
			
			# Add the edge from v_idx to j if not already added.
			if not _edge_exists(highlighted_edges[v_idx], j):
				highlighted_edges[v_idx].append([j, cost])
			
			# For symmetry, update the other vertex's edge list.
			if highlighted_edges.has(j):
				if not _edge_exists(highlighted_edges[j], v_idx):
					highlighted_edges[j].append([v_idx, cost])
			else:
				highlighted_edges[j] = [[v_idx, cost]]
	edges_finished = count_edges(highlighted_edges)

# Helper function to check if an edge already exists in an edge list.
func _edge_exists(edge_list: Array, target_idx: int) -> bool:
	for edge in edge_list:
		if edge[0] == target_idx:
			return true
	return false

func build_single_edge(v_idx1: int, v_idx2: int) -> void:
	# Check if the edge between the two vertices is visible.
	if is_edge_visible(vertices[v_idx1], vertices[v_idx2]):
		var cost = vertices[v_idx1].distance_to(vertices[v_idx2])
		# Ensure that the edge arrays for both vertices exist.
		if not highlighted_edges.has(v_idx1):
			highlighted_edges[v_idx1] = []
		if not highlighted_edges.has(v_idx2):
			highlighted_edges[v_idx2] = []
		# Add the edge in both directions (undirected graph).
		highlighted_edges[v_idx1].append([v_idx2, cost])
		highlighted_edges[v_idx2].append([v_idx1, cost])
	edges_finished = count_edges(highlighted_edges)

func is_edge_visible(p1: Vector2, p2: Vector2) -> bool:
	# Skip if both points are in the same obstacle.
	for poly in obstacles_polygon:
		if poly.find(p1) != -1 and poly.find(p2) != -1:
			return false
	# Check for intersections with obstacle edges.
	for poly in obstacles_polygon:
		for k in range(poly.size()):
			var a = poly[k]
			var b = poly[(k + 1) % poly.size()]
			if (p1 == a or p1 == b or p2 == a or p2 == b):
				continue
			if GeometryHelper.segments_intersect(p1, p2, a, b):
				return false
	return true

func build_obstacle_edges() -> void:
	var vertex_index = 2  # Starting index for obstacle vertices.
	for poly in obstacles_polygon:
		var poly_size = poly.size()
		for k in range(poly_size):
			var index_a = vertex_index + k
			var index_b = vertex_index + ((k + 1) % poly_size)
			var cost = vertices[index_a].distance_to(vertices[index_b])
			edges[index_a].append([index_b, cost])
			edges[index_b].append([index_a, cost])
		vertex_index += poly_size

func count_edges(edge_set) -> int:
	var total = 0
	for key in edge_set.keys():
		total += edge_set[key].size()
	return total / 2  # Each edge is counted twice (bidirectional)


# Display
func _draw() -> void:
	draw_circle(start_point, 10, Color(1, 0, 0))
	draw_circle(end_point, 10, Color(1, 0, 0))
	if selected_vertex_index != -1:
		draw_circle(vertices[selected_vertex_index], 7, Color(1, 1, 0))
		var line_start = vertices[selected_vertex_index]
		var line_end
		if highlighted_vertex_index != -1:
			line_end = vertices[highlighted_vertex_index]
		else:
			line_end = get_global_mouse_position()
		if is_edge_visible(line_start, line_end):
			draw_line(line_start, line_end, Color(1, 1, 0))
		else:
			draw_line(line_start, line_end, Color(1, 0, 0))
	for i in highlighted_edges.keys():
		for edge in highlighted_edges[i]:
			var j = edge[0]
			draw_line(vertices[i], vertices[j], Color(0, 1, 0))
	if highlighted_path.size() > 1:
		for i in range(highlighted_path.size() - 1):
			draw_line(highlighted_path[i], highlighted_path[i + 1], Color(0, 0, 1), 3)


func _on_return_button_pressed() -> void:
	get_tree().root.get_node('Menu').show()
	queue_free()
