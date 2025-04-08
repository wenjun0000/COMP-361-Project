extends Control



func _on_vg_button_pressed() -> void:
	get_parent().add_child(preload("res://scene/vg/vg_scene.tscn").instantiate())
	hide()


func _on_td_button_pressed() -> void:
	get_parent().add_child(preload("res://scene/td/td_scene.tscn").instantiate())
	hide()


func _on_astar_button_pressed() -> void:
	get_parent().add_child(preload("res://Astar.tscn").instantiate())
	hide()
