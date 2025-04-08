extends Node

static func dijkstra(start_index: int, goal_index: int, vertices: Array, edges: Dictionary) -> Array:
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
	
	var result = []
	var u = goal_index
	while u != -1:
		result.insert(0, vertices[u])
		u = prev[u]
	return result
