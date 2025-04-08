extends CanvasLayer

@onready var guide = %"Naviation Guide"
@onready var edge_counter: Label = %EdgeCounter
@onready var help_menu_1: ColorRect = %HelpMenu1
@onready var help_menu_2: ColorRect = %HelpMenu2
@onready var help_menu_3: ColorRect = %HelpMenu3

func _process(_delta: float) -> void:
	edge_counter.text = "Edges: %d/%d" % [get_parent().edges_finished, get_parent().edges_to_finish]
	if help_menu_1.visible or help_menu_2.visible or help_menu_3.visible:
		guide.text = "Highlight: none | Navigation: left click for next menu, right click to close menu"
	else:
		if get_parent().selected_vertex_index == -1:
			guide.text = "Highlight: vertex | Navigation: left click to select, right click to create edges"
		else:
			guide.text = "Highlight: vertex | Navigation: left click to create edge, right click to cancle selected"


func _input(event: InputEvent) -> void:
	if event is InputEventMouse:
		if event.is_action_pressed("Left"):
			if help_menu_1.visible:
				help_menu_1.hide()
				help_menu_2.show()
			elif help_menu_2.visible:
				help_menu_2.hide()
				help_menu_3.show()
		if event.is_action_pressed("Right"):
			help_menu_1.hide()
			help_menu_2.hide()
			help_menu_3.hide()


func _on_button_pressed() -> void:
	get_parent().progress_phase()


func _on_help_button_pressed() -> void:
	help_menu_1.show()
