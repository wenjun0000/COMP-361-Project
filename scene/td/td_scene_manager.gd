extends Node2D

@onready var sweep_line: Line2D = $SweepLine
@onready var v_split: Node2D = $VSplit
@onready var trapezoids: Node2D = $Trapezoids
@onready var pathing_trapezoids: Node2D = $PathingTrapezoids
@onready var graph: Node2D = $Graph
@onready var path: Node2D = $Path
@onready var final_path: Line2D = $FinalPath
@onready var ui: CanvasLayer = %UI
@onready var map_2: Node2D = $Map2
@onready var intro_ui: ColorRect = $UI/Intro
@onready var trap_graph_ui: ColorRect = $UI/Graph
@onready var trap_path_ui: ColorRect = $UI/TrapPath
@onready var final_path_ui: ColorRect = $UI/FinalPath
@onready var menu: PackedScene = preload("res://menu.tscn")

enum Phase {INTRO_UI, SWEEP_LINE, TRAP_GRAPH_UI, Graph, TRAP_PATH_UI, ALL_TRAP, FINAL_PATH_UI, FINAL_PATH}
var current_phase = Phase.INTRO_UI

func _ready() -> void:
	intro_ui.show()


func _process(delta: float) -> void:
	if current_phase == Phase.SWEEP_LINE:
		if sweep_line.position.x >= 1000:
			current_phase = Phase.TRAP_GRAPH_UI
			trap_graph_ui.show()
		sweep_line.position.x += 150*delta
		for line: Line2D in v_split.get_children():
			if line.visible == false and line.points[0].x < sweep_line.position.x:
				line.show()
		for trapezoid: Polygon2D in trapezoids.get_children():
			if trapezoid.polygon[2].x < sweep_line.position.x:
				trapezoid.show()
	elif current_phase == Phase.Graph:
		graph.modulate.a += delta * 0.25
		if graph.modulate.a >= 1:
			path.modulate.a = 1
			current_phase = Phase.TRAP_PATH_UI
			trap_path_ui.show()
	elif current_phase == Phase.ALL_TRAP:
		if sweep_line.position.x <= 0:
			current_phase = Phase.FINAL_PATH_UI
			final_path_ui.show()
			path.hide()
		sweep_line.position.x -= 150*delta
		for trapezoid : Polygon2D in pathing_trapezoids.get_children():
			if trapezoid.polygon[0].x > sweep_line.position.x:
				trapezoid.show()
		


func _on_intro_button_pressed() -> void:
	intro_ui.hide()
	current_phase = Phase.SWEEP_LINE


func _on_graph_button_pressed() -> void:
	trap_graph_ui.hide()
	current_phase = Phase.Graph
	v_split.hide()
	for obstacles in map_2.get_node('Obstacles').get_children():
		obstacles.hide()


func _on_trap_path_button_pressed() -> void:
	trap_path_ui.hide()
	current_phase = Phase.ALL_TRAP
	graph.hide()


func _on_final_path_button_pressed() -> void:
	final_path_ui.hide()
	current_phase = Phase.FINAL_PATH
	final_path.show()
	v_split.show()
	for obstacles in map_2.get_node('Obstacles').get_children():
		obstacles.show()


func _on_return_button_pressed() -> void:
	get_tree().root.get_node('Menu').show()
	queue_free()
