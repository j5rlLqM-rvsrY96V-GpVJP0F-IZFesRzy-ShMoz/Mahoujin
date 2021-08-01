#extends "res://Builder/cubeinfo.gd"
extends "res://cubeconnections.gd"

var file : File = File.new()
var fname : String = ""
var e : bool = false
export var b : bool = false
onready var viewer : PackedScene = preload("res://Builder/View.tscn")

func _save(path : String, content : Dictionary):
	if file.open(path, File.WRITE) == OK:
		file.store_string(JSON.print(content))
		file.close()
	else: print("Failed to save: ", path)

func _load(path : String):
	if file.open(path, File.READ) == OK:
		var c : String = file.get_as_text()
		file.close()
		var js = JSON.parse(c)
		if js.error == OK:
			if js.result is Dictionary:
				return js.result
	print("Failed to load: ", path)

func _on_Save():
	if !b:
		if e and !$Warning.visible:
			$Warning.show()
			$Timer.start(12)
		else:
			_save("res://"+fname, $"../../.."._get_val())
			$Load.disabled = false
			$Warning.hide()
			$Timer.stop()

func _on_Load():
	if !b:
		$"../../.."._set_val(_load("res://"+fname))
	else:
		var data = $Parser.interpret("res://"+fname)
		var nodes : Array = []
		for i in data:
			if not i[0] in chassis:
				var nam : String = get_cube_name(i[0])[0]
				for u in len(nam):
					if nam[u] == '_': nam[u] = ' '
				
				nodes.append([rand_range(0,get_viewport().size.x), rand_range(0,get_viewport().size.y),
					 nam, i[0], len(all_connections[i[0]]) ])
		
		data = {"Push": 1, "Pull": 1, "Snap": 1, "Scale": 1,
			"Nodes": nodes, "Connections": [], "Snaps": [], "Bot": fname}
		$"../../.."._set_val(data)

func _on_name(n : String):
	fname = n
	if n != "":
		if !b: $Save.disabled = false
		e = file.file_exists("res://"+n)
		$Load.disabled = !e
		if b: $View.disabled = !e
	else:
		$Load.disabled = true
		if !b: $Save.disabled = true

func _on_timeout():
	$Warning.hide()

func _on_View():
	view()

func view(data : Dictionary = {}):
	var s : Object  = viewer.instance()
	if get_tree().change_scene_to(s) != OK:
		print("Oopsie poopsie, couldn't load")
	else:
		get_tree().root.add_child(s)
		if !data.empty():
			s.tridata = data
			s.set_return_to(load("res://Planner/Planner.tscn"))
		if data.has("Bot"):
			s._load("res://"+data["Bot"])
		else:
			s._load("res://"+fname)
		$"../../..".queue_free()

func _ready():
	$Load.text = tr("KEY_LOAD")
	
	if get_node_or_null("Parser") != null:
		$Name.placeholder_text = tr("KEY_BOTNAME")
		$View.text = tr("KEY_VIEW")
	else:
		$Name.placeholder_text = tr("KEY_FILENAME")
		$Save.text = tr("KEY_SAVE")
		$Warning.text = tr("KEY_OVERWRITE_CONFIRM")
		$Warning/inst.text = tr("KEY_OVERWRITE_INSTRUCTIONS")
	

