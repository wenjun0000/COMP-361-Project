extends VBoxContainer

# gain debug background panel
@onready var debug_background : Panel = %DebugBackground

# export charsize to caculate the size of background panel
@export var charSize : Vector2 = Vector2(10, 30)

# 每帧调用的函数
func _process(_delta):
	
	# Debug.update("DebugMenu", "Debug Menu Text")
	
	# check and update
	_checkLabels()
	# adjust background panel size
	_resizeBackgroundPanel()

# check and update label
func _checkLabels():
	# if debugger size > current chilf node count
	if Debug.debugInfoArr.size() > self.get_child_count():
		# add a new label
		self.add_child(Label.new())
	# if debugger size < current chilf node count
	elif Debug.debugInfoArr.size() < self.get_child_count():
		# remove the first child node(label)
		self.remove_child(self.get_children()[0])
	else:
		# update all labels' texts
		for i in self.get_child_count():
			self.get_child(i).text = Debug.debugInfoArr[i].text

# resize background panel size
func _resizeBackgroundPanel():
	# caculate background panel width
	var _biggestString : String = ""  # storage the biggest string
	for i in self.get_child_count():
		# find the biggest string
		if _biggestString.length() < self.get_child(i).text.length():
			_biggestString = self.get_child(i).text
	# resize the background panel's width according to the biggest string
	debug_background.size.x = _biggestString.length() * charSize.x
	
	# caculate the background panel's height
	if self.get_child_count() > 0:
		# resize the background panel's height according to the child node count
		debug_background.size.y = self.get_child_count() * charSize.y
	else:
		# if there is no child node then set up the height into 0
		debug_background.size.y = 0
