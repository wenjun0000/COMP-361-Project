extends Node

# storage the debugger info
var debugInfoArr : Array = []

# DebugInfo for ID and text
class DebugInfo:
	var id : String = "id"  
	var text : String = "text"  

# add a new debugger info
func add(_id : String):
	# create new DebugInfo 
	var info = DebugInfo.new()
	info.id = _id  
	info.text = "text"  
	# put debuginfo into array
	debugInfoArr.append(info)


func remove(_id : String):
	
	for i in debugInfoArr.size():
		if str(debugInfoArr[i].id) == _id:
			
			debugInfoArr.remove_at(i)
			break  

# update debugger info
func update(_id : String, _text : String):
	
	for i in debugInfoArr.size():
		if str(debugInfoArr[i].id) == _id:
			# if find the matched id then update text
			debugInfoArr[i].text = _text
			return  

	# if can't find then create a new one
	# print("Creating " + _id)  
	add(str(_id))  # add new debugger info
	update(_id, _text)  
