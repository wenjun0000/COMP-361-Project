extends CanvasLayer

@onready var toggle_button: Button = %ToggleButton
@onready var dijkstra_button: Button = %DijkstraButton


func _on_dijkstra_button_pressed() -> void:
	get_parent().progress_phase()


func _on_toggle_button_pressed() -> void:
	get_parent().toggle_obstacles()
