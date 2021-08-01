extends "res://Builder/cubeinfo.gd"

var bot : Array
var bot_instance : Spatial
export var tridata : Dictionary
var parsed_tridata : Array
var current_selection : Array = []
var return_to : PackedScene
const look_at : Vector3 = Vector3(0,8,0)
onready var tree_root : TreeItem = $UI/Tree.create_item()
var exactlen : bool = false

func set_return_to(to : PackedScene):
	return_to = to

func remove_underscores(text : String):
	if text.substr(0, 7) == "Medium_": text.erase(0, 7)
	for t in len(text):
		if text[t] == '_': text[t] = ' '
	return text

func is_tridata_compatible():
	var botparts : Array = []
	var triparts : Array = []
	for part in $Triforcer.clean_macro(bot):
		botparts.append(part[0])
	for part in tridata["Nodes"]:
		if len(part) > 3:
			triparts.append(part[3])
	
	if len(botparts) != len(triparts):
		return false
	for part in botparts:
		if !triparts.has(part):
			return false
		elif botparts.count(part) != triparts.count(part):
			return false
	return true

func parse_tridata():
	if tridata:
		var out : Array = []
		var nodes : Array = []
		for i in tridata["Nodes"]:
			if len(i) > 3:
				nodes.append(i[3])
			else:
				nodes.append(null)
		for i in tridata["Connections"]:
			if int(i[2]):
				if nodes[i[0]] and nodes[i[0]]:
					out.append([nodes[i[0]], nodes[i[1]], int(i[2])])
		return out
	return []

func triforce():
	var data : Array = parse_tridata()
	parsed_tridata = data
	var re = $Triforcer.tryforce(bot, data)
	if re != null:
		set_tree(re)
	$UI/List/ExactLen.disabled = false

func add_to_tree(data : Array):
	var tree : Tree = $UI/Tree
	var root : TreeItem = tree_root
	
	for parts in data:
		var cate_name : String = remove_underscores(cubes[parts[0]][0])+" - "+remove_underscores(cubes[parts[1]][0])
		var n : TreeItem
		var next = root.get_children()
		while next != null:
			if cate_name == next.get_text(0):
				n = next
				break
			next = next.get_next()
		if n == null:
			n = tree.create_item(root)
			n.set_text(0, cate_name)
		#n.set_text_align(0, TreeItem.ALIGN_RIGHT)
		current_selection.append([n, null, null])
		
		for connection in parts[2]:
			var c : TreeItem = tree.create_item(n)
			var t : String = ""
			for i in connection:
				t += remove_underscores(cubes[i[0]][0])+' - '
			t.erase(len(t)-2, 2)
			c.set_text(0, t)
			c.set_tooltip(0, "Length: "+str(len(connection)))
			c.set_metadata(0, connection)
		
func set_tree(data : Array):
	var tree : Tree = $UI/Tree
	tree.clear()
	tree_root = tree.create_item()
	add_to_tree(data)


func _on_cell_selected():
	var sel : TreeItem = $UI/Tree.get_selected()
	var par : TreeItem = sel.get_parent()
	if par != null and par != $UI/Tree.get_root():
		sel.set_custom_bg_color(0, Color(0,1,0,0.15))
		var data : Array = sel.get_metadata(0)
		var created : Array = []
		for part in data:
			var p : Object = $Builder.add_part(part[0], part[1], part[2])
			created.append(p)
			add_child(p)
		for c in current_selection:
			if c[0] == par:
				if c[2] != null:
					c[2].set_custom_bg_color(0, Color(0,0,0,0))
				c[2] = sel
				if c[1] != null:
					for p in c[1]:
						p.queue_free()
				c[1] = created
				break

func _on_cam_toggle(m : bool):
	$UI.grab_focus()
	if m:
		$User/Camera.set_current(true)
	else:
		$O/Cam.set_current(true)
	$User.set_process(m)

func _on_Back():
	var re : int
	if return_to:
		var s = return_to.instance()
		re = get_tree().change_scene_to(s)
		get_tree().root.add_child(s)
		if s.name == "Planner":
			s._set_val(tridata)
	else: 
		re = get_tree().change_scene("res://Main/Main.tscn")
	if re != OK:
		print("Opsie Poopsie, couldn't load")
	else:
		queue_free()

func _on_Threads(t : String = ""):
	t = $UI/List/Threads.text
	var n : int = int(t)
	if n < 1: n = 1
	$Triforcer.thread_count = n
	$UI/List/Threads.text = str(n)

func _on_RAM(t : String = ""):
	t = $UI/List/RAM.text
	var n : float = float(t)
	if n < 0.5: n = 0.5
	if n > 32: n = 32
	$Triforcer.ram_target = n*1073741824
	$UI/List/RAM.text = str(n)

func _process(delta):
	$O.rotate_y(PI*delta/4)
	$O/Cam.look_at(look_at, Vector3.UP)

func _load(path : String):
	bot = $Parser.interpret(path)
	bot_instance = $Builder._build(bot)
	add_child(bot_instance)
	
	if !tridata.empty():
		$UI/List/Triforce.disabled = false

func _on_Triforce():
	if !tridata.empty() and bot:
		if is_tridata_compatible():
			bot_instance.queue_free()
			bot_instance = null
			triforce()
			bot_instance = $Builder._build($Triforcer.bot_data)
			add_child(bot_instance)
		else:
			$UI/List/Triforce/Anim.play("Incompatible")

func _on_Collisions(state):
	$Triforcer.try_cols = state

func _on_ExactLen(state):
	exactlen = state

func _ready():
	$User.set_process(false)
	$UI/List/Freecam.text = tr("KEY_FREECAM")
	$UI/List/Back.text = tr("KEY_BACK")
	$UI/List/Collisions.text = tr("KEY_DO_COLLISIONS")
	$UI/List/Threads.placeholder_text = tr("KEY_THREADCOUNT")
	$UI/List/RAM.placeholder_text = tr("KEY_RAMTARGET")
	$UI/List/Triforce.text = "> "+tr("KEY_TRIFORCE")+" <"
	$UI/List/Triforce/Warn.text = tr("KEY_INCOMPATIBLE_DATA")
