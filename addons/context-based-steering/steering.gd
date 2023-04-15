extends Node3D

@onready var casts = $casts
var ray_num : int
var interest : Array = []
var danger : Array = []
var chosen_dir : = Vector3.ZERO

	#count the rays and set the interest and danger arrays to their size
func _ready():
	ray_num = casts.get_child_count()
	interest.resize(ray_num)
	danger.resize(ray_num)
	
	#helper function to get the absolute direction of the specified cast
func _get_dir(num):
	var cast : RayCast3D = casts.get_child(num)
	return (-cast.global_transform.basis.z)

	#main function - 'pos' is the direction you want to go. calculates a non-colliding
	#vector to try and reach this position
func calculate_path(pos) -> Vector3:
	var dir  : Vector3 = global_transform.origin.direction_to(pos)
	interest.resize(ray_num)
	danger.resize(ray_num)
	_set_interest(dir)
	_set_danger()
	var new_dir = _decide_path()
	return new_dir
	
	#check each ray, and the closer its direction is to your preferred direction,
	#the higher the value it is. highest value gets chosen for travel
func _set_interest(prefered_direction):
	for i in ray_num:
		var d = _get_dir(i).dot(prefered_direction)
		interest[i] = max(0, d)
	
	#look for collisions in each ray direction, and eliminate and ray that collides
	#from the list of directions to go.
func _set_danger():
	for i in ray_num:
		var cast : RayCast3D = casts.get_child(i)
		var result : bool = cast.is_colliding()
		danger[i] = 1.0 if result else 0.0
	
	#puts the danger and interest lists together and makes a final decision
func _decide_path() -> Vector3:
	for i in ray_num:
		if danger[i] > 0.0:
			interest[i] = 0.0
	var dir := Vector3.ZERO
	for i in ray_num:
		dir += _get_dir(i) * interest[i]
	dir = dir.normalized()
	return dir
