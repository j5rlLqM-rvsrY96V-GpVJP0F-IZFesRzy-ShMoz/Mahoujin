extends Node

var lang : int = 0
const lang_pos : Array = [Vector2(0, 0.45), Vector2(0.51, 1)]
const langs = ["en", "ja"]

const planner : PackedScene = preload("res://Planner/Planner.tscn")
const selec : Array  = [
	preload("res://Main/Basic.tscn"),
	preload("res://Main/Bobo.tscn" ),
	preload("res://Main/About.tscn")]
const click : PackedScene = preload("res://Main/ClickAnim.tscn")
const spells : Array = [
	preload("res://Spells/Mahoujin1.png"), preload("res://Spells/Mahoujin2.png"), 
	preload("res://Spells/Mahoujin3.png"), preload("res://Spells/Mahoujin4.png"), 
	preload("res://Spells/Mahoujin5.png"), preload("res://Spells/Mahoujin6.png"), 
	preload("res://Spells/Mahoujin7.png"), preload("res://Spells/Mahoujin8.png"), 
	preload("res://Spells/Mahoujin9.png")]


func add_clickanim(pos : Vector2):
	var n = click.instance()
	n.rect_position = pos
	n.get_node("Graphical").texture = spells[round(rand_range(0, len(spells)-1))]
	n.get_node("Anim").connect("animation_finished", self, "call_remove", [n])
	$ClickAnims.add_child(n)

func call_remove(_a : String, node : Object):
	node.queue_free()


func _on_Select(selection):
	var s = selec[selection]
	var n = s.instance()
	$"Sub-Menu".add_child(n)
	$Menu/Anim.play("Select")
	var c : Object = n.get_child(0)
	if c.focus_mode != Control.FOCUS_NONE:
		c.grab_focus()
	else:
		c.get_child(0).grab_focus()

func _on_lang(l : int):
	if l != lang:
		lang = l
		$Lang/_/Selected.anchor_right = lang_pos[l].y
		$Lang/_/Selected.anchor_left = lang_pos[l].x
		TranslationServer.set_locale(langs[l])
		ProjectSettings.set_setting("global/lang", l)
		if ProjectSettings.save_custom("res://override.cfg") != OK:
			print("Failed to save settings")

func _ready():
	_on_lang(ProjectSettings.get_setting("global/lang"))

func _process(_delta):
	if Input.is_action_just_pressed("LClick"):
		add_clickanim($Menu.get_global_mouse_position())
	if Input.is_action_just_pressed("ui_focus_next") or Input.is_action_just_pressed("ui_focus_prev"):
		if $Menu.get_focus_owner() == null:
			$Menu/MainOptions/Bg/Basic.grab_focus()

func _set_val(c : Dictionary):
	var s : Object  = planner.instance()
	if get_tree().change_scene_to(s) != OK:
		print("Oopsie poopsie, couldn't load")
	else:
		get_tree().get_root().add_child(s)
		s._set_val(c)

