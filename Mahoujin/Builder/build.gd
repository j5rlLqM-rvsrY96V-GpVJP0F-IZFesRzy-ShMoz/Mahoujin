extends "res://cuberotations.gd"

var fle : File = File.new()


func get_meshinstances(n : Node):
	var out : Array = []
	if n.get_class() == "MeshInstance":
		out = [n]
	for child in n.get_children():
		out.append_array(get_meshinstances(child))
	return out

func _build(bot : Array, cols_only : bool = false):
	var n : Spatial = Spatial.new()
	for part in bot:
		var p : Spatial = add_part(part[0], part[1], part[2], cols_only)
		if len(part) > 3 and !cols_only:
			if typeof(part[3]) == TYPE_COLOR:
				var c : SpatialMaterial = SpatialMaterial.new()
				c.albedo_color = part[3]
				for i in get_meshinstances(p):
					i.mesh.surface_set_material(0, c)
		n.add_child(p)
	return n

func add_part(part : int, pos : Vector3, rot : int, cols_only : bool = false):
	var name : String = get_cube_name(part)[0]+".tscn"
	if cols_only:	name = "res://build_colls/"+name
	else:			name = "res://build_parts/"+name
	
	if fle.file_exists(name):
		var p : Spatial = ResourceLoader.load(name, "PackedScene").instance()
		p.transform.origin = pos/5
		p.transform.basis = Basis(dir[rot])
		return p
	else:
		print("Builder: No such file: ", name)



#func _ready():
#	var bot = $Parser.interpret("res://2plates.bot")
#	#2plates.bot
#	#rod3Ddiagonal.bot
#	#strut3Ddiagonalshort.bot
#	#bot.json
#	#Fijanub.bot
#	#FijaNub.bot
#	#FijaNoob.bot
#	#$Triforcer.clean_macro(bot)
#	var re = $"../Triforcer".tryforce(bot, [[3365106304, 3001609712, 2]])
##	var bot : Array = []
##	for i in len(chassis):
##		var rot = 0
##		bot.append([ chassis.keys()[i], Vector3(10*i, 0, 0), rot])
##		for c in $Triforcer.get_c_points(chassis.keys()[i], Vector3(10*i, 0, rot)):
##			bot.append([1931676396, c[1]+c[0], 0])
#	_build(bot)
#	$User/Camera.set_current(true)
