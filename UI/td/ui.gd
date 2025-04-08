extends CanvasLayer

func _on_button_pressed() -> void:
	get_parent().progress_phase()
