extends "res://cuberotations.gd"
var file : File = File.new()


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
	
	if file.file_exists(name):
		var p : Spatial = ResourceLoader.load(name, "PackedScene").instance()
		p.transform.origin = pos/5
		p.transform.basis = Basis(dir[rot])
		return p
	else:
		push_warning("Builder: No such file: "+name)
