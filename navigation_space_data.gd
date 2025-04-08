class_name NavigationSpaceData
extends Object


var boundary_polygon: PackedVector2Array
var obstacle_polygons: Array[PackedVector2Array]
var start_point: Vector2
var end_point: Vector2


func fetch_data_from_map(map: Node2D) -> void:
	boundary_polygon = map.find_child('Boundary').polygon
	for obstacle in map.find_child('Obstacles').get_children():
		obstacle_polygons.append(obstacle.polygon)
	start_point = map.find_child('Start').position
	end_point = map.find_child('End').position


func get_obstacle_verticies() -> Array[Vector2]:
	var vertices: Array[Vector2] = []
	for polygon in obstacle_polygons:
		for point in polygon:
			vertices.append(point)
	return vertices

func get_boundary_verticies() -> Array[Vector2]:
	var vertices: Array[Vector2] = []
	for point in boundary_polygon:
		vertices.append(point)
	return vertices
