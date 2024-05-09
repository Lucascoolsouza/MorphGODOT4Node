@tool
extends Node
class_name Transition_Node

@export var node_a: NodePath # Panel_a
@export var node_b: NodePath # Panel_b

@export var morph_to_node_b: bool = false:
	set(value):
		morph_to_node_b = value
		if value:
			morph_progress = 0.0
			fbackup_node_a_properties()
		else:
			morph_progress = 1.0
			restore_node_a_properties()

var node_a_properties: Dictionary = {}
var node_b_properties: Dictionary = {}
var backup_node_a_properties: Dictionary = {}

var node_a_instance: Node = null
var node_b_instance: Node = null

var morph_progress: float = 0.0

func _ready():
	if has_node(node_a):
		node_a_instance = get_node(node_a)
	if has_node(node_b):
		node_b_instance = get_node(node_b)

	if node_a_instance and node_b_instance:
		node_a_properties = get_node_properties(node_a_instance)
		node_b_properties = get_node_properties(node_b_instance)

func fbackup_node_a_properties():
	backup_node_a_properties = node_a_properties.duplicate(true)

func restore_node_a_properties():
	for property_name in backup_node_a_properties:
		node_a_instance.set(property_name, backup_node_a_properties[property_name])

func get_node_properties(node: Node) -> Dictionary:
	var properties: Dictionary = {}
	for property in node.get_property_list():
		var value = node.get(property.name)
		if value != null and (property.type == TYPE_INT or property.type == TYPE_FLOAT or property.type == TYPE_VECTOR2 or property.type == TYPE_VECTOR3 or property.type == TYPE_COLOR):
			properties[property.name] = value
	return properties

func _process(delta):
	if morph_to_node_b:
		morph_progress = min(morph_progress + delta, 1.0)
	else:
		morph_progress = max(morph_progress - delta, 0.0)

	if node_a_instance and node_b_instance:
		for property_name in node_a_properties:
			if property_name in node_b_properties:
				var src_value = node_b_properties[property_name]
				var dst_value = node_a_properties[property_name]
				var lerped_value = lerp(dst_value, src_value, morph_progress)
				node_a_instance.set(property_name, lerped_value)
