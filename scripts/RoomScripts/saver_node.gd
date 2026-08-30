@tool #allow running in editor
class_name SaverNode extends Node
###### Add a saver node as a child

const SAVER_NODE_GROUP: String = "saver_node" #group name of the nodes

@export var things_to_save:Array[String] = [] #what were saving
var suggested_properties: Array[String] = [] #hold all proporties  can save

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group(SAVER_NODE_GROUP)
	if Engine.is_editor_hint():
		_update_property_list()
	
	####find proporties with drop down list!!
func _update_property_list() -> void: #get array from parent 
	var parent = get_parent()
	if not parent:
		return
	suggested_properties.clear()
	var all_props = parent.get_property_list()
	#filier the list for just what we need
	for p in all_props:
		var pname = p.name
		suggested_properties.append(pname)
	notify_property_list_changed()
func _validate_property(property: Dictionary) -> void:
	if property.name == "things_to_save":
		var options = "'".join(suggested_properties)
		property.hint = PROPERTY_HINT_TYPE_STRING
		property.hint_string = "%d/%d:%s" % [TYPE_STRING, PROPERTY_HINT_ENUM, options]
	#####find proporties with drop down list^^^
	
func get_save_dict() -> Dictionary: #get the stuff for the dict
	var parent = get_parent()
	var node_data = {}
	for prop in things_to_save:
		print("Saving property: ", prop)
		if prop in parent:
			node_data[prop] = parent.get(prop)
	return node_data
	
func apply_save_dict(node_data: Dictionary) -> void: #put the stuff in the dict
	var parent = get_parent()
	for prop in node_data:
		if prop in parent:
			parent.set(prop, node_data[prop])
