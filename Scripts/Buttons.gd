extends Node2D

# Gain Player node
@onready var player: Node2D = %Player

# Gain button node
@onready var btn_diagonal: Button = %BtnDiagonal
@onready var btn_path_draw: Button = %"BtnPath Draw"
@onready var btn_grid_draw: Button = %"BtnGrid Draw"
@onready var btn_mouse_walk: Button = %"BtnMouse Walk"
@onready var btn_wasd_walk: Button = %"BtnWASD Walk"
@onready var main: Node2D = $"../.."

# Called when a node enters the scene tree.
func _ready():

	_updateButtonsColors()

# Update button color
func _updateButtonsColors():
	# Update button color based on player settings
	_colorBtn(btn_diagonal, bool(player.grid.diagonal_mode != AStarGrid2D.DIAGONAL_MODE_NEVER))
	_colorBtn(btn_path_draw, player.printPath)
	_colorBtn(btn_grid_draw, player.printGrid)
	_colorBtn(btn_mouse_walk, player.allowMouseInput)
	_colorBtn(btn_wasd_walk, player.allowWASDInput)

# Function to set the color of the button
func _colorBtn(btn : Button, boolean : bool):
	# Set the font color of the button based on the boolean value.
	btn.set("theme_override_colors/font_color", Color.GREEN if boolean else Color.RED)
	btn.set("theme_override_colors/font_pressed_color", Color.GREEN if boolean else Color.RED)
	btn.set("theme_override_colors/font_hover_color", Color.GREEN if boolean else Color.RED)
	btn.set("theme_override_colors/font_focus_color", Color.GREEN if boolean else Color.RED)
	btn.set("theme_override_colors/font_hover_pressed_color", Color.GREEN if boolean else Color.RED)

# called when the diagonal mode button is pressed
func _on_diagonal_mode_pressed() -> void:
	# Defines the diagonal mode constant
	const _diagonal = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
	const _grid = AStarGrid2D.DIAGONAL_MODE_NEVER
	# Check if it is diagonal mode
	var _diagonalMode = player.grid.diagonal_mode != AStarGrid2D.DIAGONAL_MODE_NEVER
	
	if _diagonalMode:
		player.grid.diagonal_mode =  _grid
	else:
		player.grid.diagonal_mode =  _diagonal
	
	_updateButtonsColors()

# toggle path 
func _on_toggle_path_pressed() -> void:
	
	player.printPath = !player.printPath
	
	_updateButtonsColors()

# toggle grid 
func _on_toggle_grid_pressed() -> void:
	# switch to toggle grid
	player.printGrid = !player.printGrid
	
	_updateButtonsColors()

# toggle mouse walk
func _on_toggle_mouse_walk_pressed() -> void:
	
	player.allowMouseInput = !player.allowMouseInput
	
	_updateButtonsColors()

# WASD
func _on_toggle_WASD_movement_pressed() -> void:
	
	player.allowWASDInput = !player.allowWASDInput
	
	_updateButtonsColors()


func _on_return_button_pressed() -> void:
	get_tree().root.get_node('Menu').show()
	main.queue_free()
