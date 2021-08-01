extends "res://cubeconnections.gd"
#orth index: rotation

const dir : Dictionary = {
	0:  Vector3(    0,    0,    0),		1:  Vector3(    0,    0, PI/2),
	2:  Vector3(    0,    0,   PI),		3:  Vector3(    0,    0,-PI/2),
	4:  Vector3(    0, PI/2,    0),		5:  Vector3(    0, PI/2, PI/2),
	6:  Vector3(-PI/2,-PI/2,    0),		7:  Vector3(    0, PI/2,-PI/2),
	8:  Vector3(    0,-PI/2, PI/2),		9:  Vector3(    0,-PI/2,-PI/2), 
	10: Vector3( PI/2,-PI/2,    0),		11: Vector3( PI/2,-PI/2,   PI),
	12: Vector3(-PI/2,-PI/2,   PI),		13: Vector3(    0, PI/2,   PI), 
	14: Vector3(    0,   PI,    0),		15: Vector3(    0,   PI, PI/2), 
	16: Vector3(    0,   PI,   PI),		17: Vector3(    0,   PI,-PI/2), 
	18: Vector3(    0,-PI/2,    0),		19: Vector3(    0,-PI/2,   PI),
	20: Vector3( PI/2,-PI/2,-PI/2),		21: Vector3( PI/2,-PI/2, PI/2),
	22: Vector3(-PI/2,-PI/2, PI/2),		23: Vector3(-PI/2,    0,   PI)}
