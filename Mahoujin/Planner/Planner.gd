extends Control

const Element : PackedScene = preload("res://Planner/Element.tscn")
const Connection : PackedScene = preload("res://Planner/Connection.tscn")
const Snap : PackedScene = preload("res://Planner/Snap.tscn")
var selected
export var push : float = 1.0
var pull : float = 1.0
var snap : float = 1.0
var scale : float = 1.0
export var bot : String
const spells : Array = [
	preload("res://Spells/Mahoujin1.png"), preload("res://Spells/Mahoujin2.png"), 
	preload("res://Spells/Mahoujin3.png"), preload("res://Spells/Mahoujin4.png"), 
	preload("res://Spells/Mahoujin5.png"), preload("res://Spells/Mahoujin6.png"), 
	preload("res://Spells/Mahoujin7.png"), preload("res://Spells/Mahoujin8.png"), 
	preload("res://Spells/Mahoujin9.png")]

func add_element(pos):
	var n = Element.instance()
	var l = n.get_node("LineEdit")
	$Items/Elements.add_child(n)
	n.rect_position = pos
	n.get_node("Txre-Btn").connect("pressed", $".", "act_connection", [n])
	n.rect_scale = Vector2(scale, scale)
	l.rect_pivot_offset = l.rect_size/2
	l.rect_scale = Vector2(1/scale, 1/scale)
	return n

func add_connection(r, l):
	var n = Connection.instance()
	$Items/Connections.add_child(n)
	n.right = r
	n.left = l
	r.consleft -= 1
	l.consleft -= 1
	n.update()
	return n

func act_connection(elemnt):
	if Input.is_action_pressed("ui_cancel"):
		remove_element(elemnt)
	elif selected and selected != elemnt and !check_connection(elemnt, selected):
		if elemnt.consleft > 0 and selected.consleft > 0:
			add_connection(selected, elemnt)
		selected = null
		$GUI/Preview.hide()
	else:
		selected = elemnt
		$GUI/Preview.right = elemnt
		$GUI/Preview.show()

func add_snap(pos=Vector2.ZERO, r=1):
	var n = Snap.instance()
	$Snaps/_.add_child(n)
	n.radius = r
	n.rect_position = pos
	n.update()

func check_connection(right, left):
	for i in $Items/Connections.get_children():
		if i.right == right or i.left == right:
			if i.left == left or i.right == left:
				return true
	return false

func remove_element(elemnt):
	for i in $Items/Connections.get_children():
		if i.right == elemnt or i.left == elemnt:
			i.remove()
	elemnt.queue_free()

func _process(delta):
	if !Input.is_action_pressed("ui_cancel"):
		if Input.is_action_just_pressed("MClick"):
			add_snap(get_global_mouse_position())
		if Input.is_action_just_pressed("RClick"):
			add_element(get_global_mouse_position())
	if Input.is_action_just_pressed("ui_focus_next") or Input.is_action_just_pressed("ui_focus_prev"):
		if get_focus_owner() == null:
			$GUI/List/View.grab_focus()
	
	if selected:
		$GUI/Preview.update(get_global_mouse_position())
		if Input.is_action_pressed("ui_cancel"):
			$GUI/Preview.hide()
			selected = null
	
	for c in $Items/Connections.get_children():
		var r = c.right
		var l = c.left
		var d = r.rect_position.distance_to(l.rect_position)
		
		if d*pull > 200:
			r.c += r.rect_position.move_toward(l.rect_position, delta*d*d*d*0.0000001*pull)-r.rect_position
			l.c += l.rect_position.move_toward(r.rect_position, delta*d*d*d*0.0000001*pull)-l.rect_position
		c.update()
	
	for s in $Snaps/_.get_children():
		for e in $Items/Elements.get_children():
			var angle = e.rect_position.angle_to_point(s.rect_position)
			var s_pos = Vector2(cos(angle), sin(angle))*250*s.radius+s.rect_position
			var d = e.rect_position.distance_squared_to(s_pos)
			if d < 5000*snap and d > 0:
				e.c += e.rect_position.move_toward(s_pos, snap*50000*delta/d)-e.rect_position
	
	#Clamping
	var lowerbounds : Vector2 = Vector2(12, 12)
	var upperbounds : Vector2 = get_viewport_rect().size - Vector2(12, 12)
	for e in $Items/Elements.get_children():
		e.c += e.calc_vector()*delta*push
		e.rect_position.x = clamp(e.rect_position.x + e.c.x, lowerbounds.x, upperbounds.x)
		e.rect_position.y = clamp(e.rect_position.y + e.c.y, lowerbounds.y, upperbounds.y)
		e.c = Vector2.ZERO

func _Push_changed(n):
	n = float(n)
	if n < 999:
		push = n
	else:
		push = 999
func _Pull_changed(n):
	n = float(n)
	if n < 999:
		pull = n
	else:
		pull = 999
func _Snap_changed(n):
	n = float(n)
	if n < 999:
		snap = n
	else:
		snap = 999
func _Scale_changed(n):
	n = float(n)
	if n <= 3 and n >= 0.1:
		scale = n
		for e in $Items/Elements.get_children():
			e.rect_scale = Vector2(n, n)
			var l = e.get_node("LineEdit")
			l.rect_pivot_offset = l.rect_size/2
			l.rect_scale = Vector2(1/n, 1/n)
		for c in $Items/Connections.get_children():
			c.get_node("Graphical").width = 2*n

func _on_preview(state):
	var l : Array = [$GUI/List/Loader, $GUI/List/BLoader, $GUI/List/Triforce]
	for i in l:
		i.visible = state
	state = !state
	l = [$GUI/List/Pull, $GUI/List/Push, $GUI/List/Scale, $GUI/List/Snap, $Snaps/_]
	for i in l:
		i.visible = state
	var t = ''
	if state:
		t = '?'
	for i in $Items/Connections.get_children():
		i.get_node("ColorPicker").visible = state
		i.get_node("LineEdit").placeholder_text = t
	for i in $Items/Elements.get_children():
		i.get_node("LineEdit").placeholder_text = t

func _get_val():
	var nodes : Array = []
	var elmts : Array = []
	for i in $Items/Elements.get_children():
		if i.id:
			nodes.append([i.rect_position.x, i.rect_position.y, i.get_node("LineEdit").text, i.id, i.consleft])
		else:
			nodes.append([i.rect_position.x, i.rect_position.y, i.get_node("LineEdit").text])
		elmts.append(i)
	var connections : Array = []
	for i in $Items/Connections.get_children():
		var colour = i.get_node("Graphical").default_color
		connections.append([elmts.find(i.right), elmts.find(i.left), i.get_node("LineEdit").text, [colour.r,colour.g,colour.b]])
	var snaps : Array = []
	for i in $Snaps/_.get_children():
		snaps.append([i.rect_position.x, i.rect_position.y, i.radius])
	var c : Dictionary = {
		"Push": push,
		"Pull": pull,
		"Snap": snap,
		"Scale": scale,
		"Nodes": nodes,
		"Connections": connections,
		"Snaps": snaps}
	if bot: c["Bot"] = bot
	return c

func _set_val(c : Dictionary):
	for i in $Items/Elements.get_children():
		remove_element(i)
	for i in $Snaps/_.get_children():
		i.remove()
	var nodes : Array = []
	for i in c["Nodes"]:
		var e = add_element(Vector2(i[0],i[1]))
		nodes.append(e)
		e.get_node("LineEdit").text = i[2]
		if len(i) > 3:
			e.id = i[3]
			e.consleft = i[4]
	for i in c["Connections"]:
		var e = add_connection(nodes[i[0]],nodes[i[1]])
		e.get_node("LineEdit").text = i[2]
		e.get_node("Graphical").default_color = Color(i[3][0],i[3][1],i[3][2])
		e.get_node("ColorPicker").color = Color(i[3][0],i[3][1],i[3][2])
		
	for i in c["Snaps"]:
		add_snap(Vector2(i[0], i[1]), i[2])
	push = c["Push"]
	pull = c["Pull"]
	snap = c["Snap"]
	if c.has("Bot"):
		bot = c["Bot"]
	_Scale_changed(c["Scale"])

func _on_Help(state):
	$GUI/Help/Text.visible = state 

func call_remove(_s : String = "", r : Node = null):
	r.queue_free()

func _on_Triforce():
	if bot:
		var pas : bool = true
		for c in $Items/Connections.get_children():
			var t : String = c.get_node("LineEdit").text
			var tt : String = str(int(t))
			if tt != t:
				pas = false
				c.get_node("LineEdit").text = tt
				var a : Object = load("res://Main/ClickAnim.tscn").instance()
				a.rect_position = c.get_node("LineEdit").rect_position+c.get_node("LineEdit").rect_size/2
				a.get_node("Graphical").texture = spells[round(rand_range(0, len(spells)-1))]
				a.get_node("Anim").connect("animation_finished", self, "call_remove", [a])
				$GUI.add_child(a)
		if pas:
			var val : Dictionary = _get_val()
			$GUI/List/BLoader.view(val)
		else:
			$GUI/List/Triforce/Anim.play("Invalid_Length")

func _ready():
	$GUI/Help/Text.text = tr("KEY_PLANNERHELP")
	$GUI/List/Push.placeholder_text = tr("KEY_PUSHFORCE")
	$GUI/List/Pull.placeholder_text = tr("KEY_PULLFORCE")
	$GUI/List/Snap.placeholder_text = tr("KEY_SNAPFORCE")
	$GUI/List/Scale.placeholder_text = tr("KEY_NODESCALE")
	$GUI/List/Triforce.text = tr("KEY_TRIFORCE")
	$GUI/List/Triforce/Warn.text = tr("KEY_INVALID_LENGTH")
	
