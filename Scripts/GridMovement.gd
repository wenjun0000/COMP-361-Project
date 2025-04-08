extends CharacterBody2D

# gain player node
@onready var player: Node2D = %Player
# control WASD 
var flippingBool : bool = false

# grid relate variance
@onready var tileMap: TileMap = %TileMap  #  TileMap 
@onready var tileSize = tileMap.tile_set.tile_size  # Tile size
@onready var finalTile : Vector2 = player.position  # player's position
var grid: AStarGrid2D  # A* grid
var idPath: PackedVector2Array  # storage path's array

var printPath : bool = true  # whether printpath
var printGrid : bool = true  # whether printgrid
var allowMouseInput : bool = true  # whether allow mouse input
var allowWASDInput : bool = true  # whether allow wasd input

# iniate function
func _ready():	
	print(str(self.position))  # print player iniate position
	# update debug info
	Debug.update("helpText1", "Walk with WASD/Arrow keys")
	Debug.update("helpText2", "Or use Mouse click/Space bar")
	Debug.update("helpText3", " ")


	_startGrid()  # iniate grid
	_setWalkableTiles()  # set up walkable tiles

# draw function
func _draw():
	_drawPathToWalk()  
	_drawMapTiles()  

# Function called per frame
func _process(_delta):
	_playerWalk()  # handel player walk
	queue_redraw()  

	
	Debug.update("PlayerGrid", "Pathwalk From: " + str(tileMap.local_to_map(player.position)) + ", To: " + str(tileMap.local_to_map(finalTile)))
	Debug.update("MouseGrid", "Mouse tile: " + str(tileMap.local_to_map(get_global_mouse_position())))

# input handel event function
func _input(event):
	# mouse input
	if allowMouseInput:
		if event.is_action_pressed("ui_accept"):
			# if mouse clicks position which is walkable tile then update target postion
			if _isWalkableTile(tileMap.local_to_map(get_global_mouse_position())):
				finalTile = get_global_mouse_position()

#region grid initialization

#  grid initialization
func _startGrid():	
	grid = AStarGrid2D.new()  # set up A* grid
	grid.region = tileMap.get_used_rect()  # set up grid space into TileMap usage space
	grid.cell_size = tileMap.tile_set.tile_size  # grid cell size
	grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER  # dignoal mode 
	grid.update()  

# set walkable tiles
func _setWalkableTiles():
	for x in tileMap.get_used_rect().size.x:
		for y in tileMap.get_used_rect().size.y:
			var _gridTile = Vector2i(x + tileMap.get_used_rect().position.x, y + tileMap.get_used_rect().position.y)
			# if tiles don't walk then set up into solid
			if !_isWalkableTile(_gridTile):
				grid.set_point_solid(_gridTile)

#endregion

#region player move

# handel player walk
func _playerWalk():
	if idPath.size() < 2:
		_updatePathToWalk()  # if path is less than 2, then update path
		return

	var _targetPos = idPath[1]  # gain the next target position
	var _speed = 1.5  # move speed

	# move to target position
	player.global_position = player.global_position.move_toward(_targetPos, _speed)

# if it arrives target position then Then remove the points that have been reached

	if player.global_position.distance_to(_targetPos) < 0.1:
		idPath.remove_at(0)  # Remove the current position point instead of recalculating the entire path
		if idPath.size() < 2:
			_updatePathToWalk()  # Recalculate only when all paths have been exhausted

# update path
func _updatePathToWalk():
	_wasdInput()  # handel WASD input

	var _from = tileMap.local_to_map(player.position)  # Obtain the tile coordinates of the player's current location
	var _to = tileMap.local_to_map(finalTile)  # Gain the tile coordinates of the target position

	idPath = grid.get_id_path(_from, _to)  # Gain path

	for i in idPath.size():  # Fix the location in the path
		idPath[i] = tileMap.map_to_local(idPath[i])

# Check whether the tiles are walkable
func _isWalkableTile(tile : Vector2i) -> bool:
	# Ground floor: If it is not the ground floor, do not walk on it
	var _groundLayer = 1
	if !tileMap.get_cell_tile_data(_groundLayer, tile):
		return false

	# Covering: If it is a covering, it is not walkable
	var _overlayLayer = 2
	if tileMap.get_cell_tile_data(_overlayLayer, tile):
		return false

	return true

#endregion

#region WASD to move

# Handel WASD input
func _wasdInput():	
	if !allowWASDInput:	return

	# Define the direction and magnitude of a vector
	var _walkVector = Vector2.ZERO
	var actions = ["ui_left", "ui_right", "ui_up", "ui_down"]
	var directions = [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]

	flippingBool = !flippingBool  # switching the input order
	var order = [0, 1, 2, 3] if flippingBool else [3, 2, 1, 0]

	for i in order:
		_walkVector = _keyboardPressed(actions[i], _walkVector, directions[i])

	Debug.update("_walkVector", "WASD Walk: " + str(_walkVector / Vector2(tileSize)))

	if _walkVector:
		finalTile = player.position + _walkVector  # Update destination

# Handle keyboard keys
func _keyboardPressed(keyPressed : String, _walkVector : Vector2, _position : Vector2 ) -> Vector2:
	var _noDiagonal = grid.diagonal_mode == AStarGrid2D.DIAGONAL_MODE_NEVER  # 是否允许对角线移动
	_position *= Vector2(tileSize)  # adjustment position vector

	if Input.is_action_pressed(keyPressed):
		if _noDiagonal:
			if _isWalkableTile(tileMap.local_to_map(player.position + _position)):
				return _position
		else:
			if _isWalkableTile(tileMap.local_to_map(player.position + _walkVector + _position)):
				return _walkVector + _position
			elif _isWalkableTile(tileMap.local_to_map(player.position + _position)):
				return _position

	return _walkVector

#endregion

#region draw tiles

# draw tile map
func _drawMapTiles():
	var _playerTile : Rect2  # player's tile
	var _targetTile : Rect2  # Target Tile

	if tileMap:
		# Draw the squares on the tiles
		var _terrainCell = 1
		var arrayOfCells = tileMap.get_used_cells(_terrainCell)  # 获取地形瓦片
		for i in arrayOfCells.size():
			# Create tile rectangle
			var _cellX = arrayOfCells[i].x * tileSize.x - get_transform().origin.x  # 修正原点位置
			var _cellY = arrayOfCells[i].y * tileSize.y - get_transform().origin.y  # 修正原点位置
			var _tile = Rect2(_cellX, _cellY, tileSize.x, tileSize.y)

			# Update player tile
			var _isPlayer = tileMap.local_to_map(player.position) == Vector2i(arrayOfCells[i].x, arrayOfCells[i].y)
			if (_isPlayer):
				_playerTile = _tile

			# Update target tile
			var _isWalkTarget = tileMap.local_to_map(finalTile) == Vector2i(arrayOfCells[i].x, arrayOfCells[i].y)
			if (_isWalkTarget):
				_targetTile = _tile

			# Draw a red grid on all walkable tiles
			if printGrid:
				_printTile(_tile)

	# Draw the target tile above the red grid
	if printPath:
		_printTile(_targetTile, Color.GREEN)
	# Draw the player tile above the red grid
	if printPath:
		_printTile(_playerTile, Color.BLUE)

# Draw Tiles
func _printTile(tile : Rect2, color : Color = Color(0.7, 0.7, 0.7, 1.0)):
	if tile:
		draw_rect(tile, color, false) 

# Draw path
func _drawPathToWalk():	
	if idPath.size() < 2 || !printPath:	return

	# Draw Path polyline
	var _fixedVectors = idPath.duplicate()
	for i in _fixedVectors.size():
		_fixedVectors[i] -= player.position
	draw_polyline(_fixedVectors, Color.RED)

	# Draw a circle in the center of the tile
	for i in idPath.size():
		draw_circle(idPath[i] - player.position, 1, Color.RED)
#endregion
