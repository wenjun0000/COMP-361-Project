extends Node2D

# Define an example obstacle polygon (in clockwise or counter-clockwise order)
var obstacle_polygon = [
	Vector2(100, 150),
	Vector2(300, 100),
	Vector2(350, 250),
	Vector2(250, 350),
	Vector2(100, 300)
]

# Array to hold computed vertical segments.
# Each element is a Dictionary with keys:
#    "vertex": the original vertex,
#    "lower": the lower intersection,
#    "upper": the upper intersection.
var vertical_segments = []

# Array to hold trapezoidal regions.
# Each trapezoid is represented as an array of 4 Vector2 corner points.
var trapezoids = []

func _ready():
	compute_vertical_segments()
	compute_trapezoids()  # This is a simplified method for demonstration.
	queue_redraw()

### STEP 2.1: Compute Vertical Segments from Each Vertex ###
func compute_vertical_segments():
	vertical_segments.clear()
	var n = obstacle_polygon.size()
	for i in range(n):
		var v = obstacle_polygon[i]
		var intersections = []
		# For each edge of the polygon, check for intersection with the vertical line x = v.x
		for j in range(n):
			var a = obstacle_polygon[j]
			var b = obstacle_polygon[(j + 1) % n]
			# If the x-coordinates of a and b straddle v.x, there is a potential intersection.
			if (a.x - v.x) * (b.x - v.x) <= 0:
				# Avoid division by zero if the edge is vertical.
				if abs(b.x - a.x) < 0.001:
					continue
				# Find interpolation factor t
				var t = (v.x - a.x) / (b.x - a.x)
				if t >= 0 and t <= 1:
					# Compute the y-coordinate of the intersection.
					var intersect_y = lerp(a.y, b.y, t)
					intersections.append(Vector2(v.x, intersect_y))
		# Sort intersections by y to easily find the ones just below and above v.
		intersections.sort_custom(compare_by_y)
		var lower = null
		var upper = null
		for point in intersections:
			if point.y < v.y:
				if lower == null or point.y > lower.y:
					lower = point
			elif point.y > v.y:
				if upper == null or point.y < upper.y:
					upper = point
		if lower and upper:
			vertical_segments.append({ "vertex": v, "lower": lower, "upper": upper })

# Helper function to sort Vector2 objects by their y-coordinate.
func compare_by_y(a: Vector2, b: Vector2) -> int:
	if a.y < b.y:
		return -1
	elif a.y > b.y:
		return 1
	else:
		return 0

### STEP 2.2: Generate Simplified Trapezoidal Regions ###
func compute_trapezoids():
	trapezoids.clear()
	# For a simple demonstration, sort vertical segments by the x-coordinate of their vertex.
	vertical_segments.sort_custom(compare_segments_by_x)
	# Create trapezoids between adjacent vertical segments.
	for i in range(vertical_segments.size() - 1):
		var seg_left = vertical_segments[i]
		var seg_right = vertical_segments[i + 1]
		# For the top boundary, take the lower (i.e. higher on screen) of the two upper intersection points.
		var top_y = min(seg_left.upper.y, seg_right.upper.y)
		# For the bottom boundary, take the higher (i.e. lower on screen) of the two lower intersection points.
		var bottom_y = max(seg_left.lower.y, seg_right.lower.y)
		# Define the four corners of the trapezoid.
		var p1 = Vector2(seg_left.vertex.x, bottom_y)
		var p2 = Vector2(seg_right.vertex.x, bottom_y)
		var p3 = Vector2(seg_right.vertex.x, top_y)
		var p4 = Vector2(seg_left.vertex.x, top_y)
		# Only add a valid trapezoid if the top is above the bottom.
		if top_y > bottom_y:
			trapezoids.append([p1, p2, p3, p4])

# Helper to compare vertical segments by the x-coordinate of their vertex.
func compare_segments_by_x(a, b) -> int:
	if a["vertex"].x < b["vertex"].x:
		return -1
	elif a["vertex"].x > b["vertex"].x:
		return 1
	else:
		return 0

### STEP 2.3: Render the Algorithm Using draw_line() and draw_polygon() ###
func _draw():
	# Draw the obstacle polygon (filled) with a light gray color.
	draw_polygon(obstacle_polygon, [Color(0.8, 0.8, 0.8)])
	
	# Draw the polygon outline in black.
	var n = obstacle_polygon.size()
	for i in range(n):
		draw_line(obstacle_polygon[i], obstacle_polygon[(i + 1) % n], Color(0, 0, 0), 2)
	
	# Draw vertical segments in red and mark the originating vertex in blue.
	print(vertical_segments)
	for seg in vertical_segments:
		draw_line(seg["lower"], seg["upper"], Color(1, 0, 0), 2)
		draw_circle(seg["vertex"], 4, Color(0, 0, 1))
	
	# Draw the trapezoids in a semi-transparent green.
	print(trapezoids)
	for trap in trapezoids:
		draw_polygon(trap, [Color(0, 1, 0, 0.3)])
		# Draw the outline of each trapezoid.
		for i in range(trap.size()):
			draw_line(trap[i], trap[(i + 1) % trap.size()], Color(0, 1, 0), 2)
