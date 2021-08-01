extends Spatial

var speed : int = 10
var sensivity : float = 0.5
onready var mpos : Vector2 = $M.get_global_mouse_position()

func _process(delta):
	#Position
	var v : Vector3 = Vector3.ZERO
	if Input.is_action_pressed("Forward"):	v.z -= 1
	if Input.is_action_pressed("Backward"):	v.z += 1
	if Input.is_action_pressed("Right"):	v.x += 1
	if Input.is_action_pressed("Left"):		v.x -= 1
	if Input.is_action_pressed("Up"):		v.y += 1
	if Input.is_action_pressed("Down"):		v.y -= 1
	v = v.normalized()
	translate(v*delta*speed)
	
	#Orientation
	if $M.get_global_mouse_position() != mpos:
		var m : Vector2 = Input.get_last_mouse_speed()/$M.get_viewport().size*sensivity
		var axis : Vector3 = Vector3(-cos(rotation.y), 0, sin(rotation.y))
		global_rotate(Vector3(0,1,0), -m.x)
		rotate(axis, m.y)
		mpos = $M.get_global_mouse_position()
	
