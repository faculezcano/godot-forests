tool
extends Spatial

class_name Leaves


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export (NodePath) var path;
var node_path = NodePath("position:x");
var property_path = node_path.get_as_property_path();

# Called when the node enters the scene tree for the first time.
func _ready():
	print(path);
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
