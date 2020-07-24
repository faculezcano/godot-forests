tool
extends Spatial

class_name Branch

var _currentIteration: int = 0;
export var iteration: int = 0 setget set_iteration;

var _currentBranches: int = 0;
export var branches: int = 0 setget set_branches;

export var direction: Vector3 = Vector3(0, 1, 0) setget set_direction;
export var direction_deviation: Vector3 = Vector3() setget set_direction_deviation;

export var Seed: int = 0 setget set_seed;
var rng = RandomNumberGenerator.new()

export var radius: float = 0.05;
export var sides: int = 5;

var startPoint: Vector3 = Vector3();
var _lastPoint: Vector3 = Vector3(0,0,0);

var _polygon: PoolVector2Array = PoolVector2Array();

var csg: CSGPolygon;

var path: Path;
var branches_node: Spatial;
# Called when the node enters the scene tree for the first time.
func _ready():
	var ray = Vector2(radius, 0);
	
	for i in sides:
		_polygon.push_back(ray);
		ray = ray.rotated(2*PI/sides);
	reset();
	update();
	pass # Replace with function body.

func randomVector3(mean: Vector3 = Vector3(), deviation: Vector3 = Vector3()) -> Vector3:
	var output: Vector3 = Vector3();
	output.x = rng.randfn(mean.x, deviation.x);
	output.y = rng.randfn(mean.y, deviation.y);
	output.z = rng.randfn(mean.z, deviation.z);
	return output;

func update():
	if(path == null):
		return
	#reset(); # debug
	while _currentIteration < iteration :
		_lastPoint = _lastPoint+randomVector3(direction, direction_deviation);
		path.get_curve().add_point(_lastPoint);
		branches();
		_currentIteration+=1
	pass

func reset():
	if(get_parent() == null):
		return
	for child in get_children():
		child.queue_free()
	path = Path.new();
	branches_node = Spatial.new();
	branches_node.name = 'Branches';
	add_child(path);
	path.set_owner(get_tree().edited_scene_root);
	add_child(branches_node);
	branches_node.set_owner(get_tree().edited_scene_root);
	rng.set_seed(Seed);
	path.set_curve(Curve3D.new());
	_lastPoint = startPoint;
	_currentIteration = 0;
	_currentBranches = branches;
	path.get_curve().add_point(_lastPoint);
	
	csg = CSGPolygon.new();
	csg.smooth_faces = true;
	csg.mode = CSGPolygon.MODE_PATH;
	csg.invert_faces = true;
	csg.polygon = _polygon;
	csg.path_node = path.get_path();
	add_child(csg);
	csg.set_owner(get_tree().edited_scene_root);
	

func set_iteration(value: int):
	if(value < iteration):
		reset();
	iteration = value;
	update();
	
func set_direction(value: Vector3):
	direction = value;
	reset();
	update();

func set_seed(value: int):
	Seed = value;
	reset();
	update();

func set_direction_deviation(value: Vector3):
	direction_deviation = value;
	reset();
	update();
	
func set_branches(value: int):
	branches = value;
	reset();
	update();

func branches():
	var branches = branches_node.get_children();
	for branch in branches:
		branch.set_iteration(branch.iteration+1);
		branch.update();

	if(_currentBranches > 0):
		if(rng.randi_range(0,1) == 1):
#			var branch_direction = (direction + Vector3(0.5, 0, 0)).normalized();
#			branch_direction = branch_direction.rotated(Vector3(0, 1, 0), rng.randf_range(0, 2*PI));
#			direction = branch_direction.rotated(Vector3(0, 1, 0), PI);
			var new_branch = get_script().new();
			new_branch.Seed = rng.randi();
			new_branch.translate(_lastPoint);
			new_branch.rotate_x(PI/4);
			new_branch.rotate_y(rng.randf_range(0, 2*PI));
#			new_branch.set_direction(branch_direction);
			new_branch.set_direction_deviation(direction_deviation);
			new_branch.radius = radius*0.5*(iteration-_currentIteration)/iteration;
			new_branch.sides = sides;
	
			branches_node.add_child(new_branch);
			new_branch.set_owner(get_tree().edited_scene_root);
			_currentBranches-=1;
