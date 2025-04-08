extends Node

static func segments_intersect(p1: Vector2, p2: Vector2, p3: Vector2, p4: Vector2) -> bool:
	var d1 = direction(p3, p4, p1)
	var d2 = direction(p3, p4, p2)
	var d3 = direction(p1, p2, p3)
	var d4 = direction(p1, p2, p4)
	
	if ((d1 > 0 and d2 < 0) or (d1 < 0 and d2 > 0)) and ((d3 > 0 and d4 < 0) or (d3 < 0 and d4 > 0)):
		return true
	return false

static func direction(pi: Vector2, pj: Vector2, pk: Vector2) -> float:
	return (pk - pi).cross(pj - pi)
