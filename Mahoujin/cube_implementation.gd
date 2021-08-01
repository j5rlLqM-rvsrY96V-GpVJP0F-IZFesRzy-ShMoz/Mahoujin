extends Spatial
#extends "res://build_cube_transforms.gd"
#tool
#
##[name, [pos, rot, scale], [extra properties], [children]]
#
##Extra properties:
##["Properties", mass, physics mass, drag, angular drag, is COM custom, custom COM]
##["Mesh", mesh name]
##["MeshCollider", is convex, mesh name]
##["BoxCollider", center pos, size]
##["SphereCollider", center pos, radius]
##["CapsuleCollider", center pos, radius, heigth, direction]
#
#export var activate : bool = false setget yayeet
#var file = File.new()
#var edit = EditorPlugin.new()
##var cube_implementations : Array = [build_chassis, build_movement, build_weapons, build_special, build_cosmetic]
#
#func implement():
#	#for i in cube_implementations:
#	for item in cube_implementations:
#		var n : Spatial
#		n = setup_node(item, $".")
#		if n == null:
#			print(item[0])
#			break
#		n.transform.origin = Vector3(0,0,0)
#		self.name = item[0]
#		edit.get_editor_interface().save_scene_as("res://build_colls/"+item[0]+".tscn", false)
#		remove_child(n)
#		n.queue_free()
#		n.owner = null
#	#edit.get_editor_interface().open_scene_from_path("res://Implementator.tscn")
#	return
#
#func get_model_file(name : String):
#	var l : Array = ["chassis", "movement", "weapons", "special", "none-type", "cosmetic"]
#	for ll in l:
#		ll = "res://models/"+ll+"/"+name+".obj"
#		if file.file_exists(ll):
#			return ll
#	print(name)
#	return ""
#
#func set_transfrm(n : Spatial, t : Array):
#	var tr : Transform = Transform(t[1].normalized().inverse())
#	tr.basis = tr.basis.scaled(t[2]).transposed()
#	tr.origin = t[0]
#	n.transform = tr
#	#Maff.
#
#func setup_node(data : Array, par : Node):
#	var n : Spatial
#	var s : bool = false
#	for i in data[2]:
#		if data[0] == "RC_HemispherePlus_Collision":
#			n = Area.new()
#			par.add_child(n)
#			break
#		elif i[0] == "Mesh":
#			continue
#
##			if "collision" in data[0].to_lower() or "COL" in data[0]: continue
##			n = MeshInstance.new()
##			n.mesh = load(get_model_file(i[1]))
##			n.cast_shadow = GeometryInstance.SHADOW_CASTING_SETTING_OFF
##			par.add_child(n)
#			break
#		elif i[0] in ["BoxCollider", "MeshCollider", "SphereCollider", "CapsuleCollider"]:
#			n = Area.new()
#			par.add_child(n)
#			break
#	for i in data[2]:
#		if i[0] == "BoxCollider":
#			var shape : CollisionShape = CollisionShape.new()
#			shape.transform.origin = i[1]#.rotated(Vector3.UP, PI/2)#*Vector3(-1,1,1)
#			#shape.transform.basis = shape.transform.basis.transposed()#rotated(Vector3.UP, PI/2)
#			var box : BoxShape = BoxShape.new()
#			box.extents = i[2]/2
#			shape.shape = box
#			n.add_child(shape)
#			shape.owner = $"."
#		elif i[0] == "MeshCollider" and i[2] != "":
#			var shape : CollisionShape = CollisionShape.new()
#			var poly 
#			var m : Mesh = load(get_model_file(i[2]))
#			if m != null:
#				if i[1]:
#					poly = m.create_convex_shape()
#				else:
#					poly = m.create_trimesh_shape()
#			shape.shape = poly
#			n.add_child(shape)
#			shape.owner = $"."
#		elif i[0] == "SphereCollider":
#			var shape : CollisionShape = CollisionShape.new()
#			shape.transform.origin = i[1]
#			var sphere : SphereShape = SphereShape.new()
#			sphere.radius = i[2]
#			shape.shape = sphere
#			n.add_child(shape)
#			shape.owner = $"."
#		elif i[0] == "CapsuleCollider":
#			var shape : CollisionShape = CollisionShape.new()
#			shape.transform.origin = i[1]
#			var capsule : CapsuleShape = CapsuleShape.new()
#			capsule.radius = i[2]
#			capsule.height = i[3]
#			shape.shape = capsule
#			n.add_child(shape)
#			shape.owner = $"."
#	if n == null:
#		if data[3] == []:
#			return
#		n = Spatial.new()
#		par.add_child(n)
#		s = true
#
#	set_transfrm(n, data[1])
#	n.name = data[0]
#	n.owner = $"."
#
#	var is_tail : bool = true
#	if data[3] != []:
#		for child in data[3]:
#			var _c = setup_node(child, n)
#			if _c != null:
#				is_tail = false
#	if is_tail == true:
#		if s == true or not n is Area:
#			n.queue_free()
#			n.owner = null
#			par.remove_child(n)
#			return
#
#	return n
#
#func yayeet(val):
#	if val:
#		implement()
