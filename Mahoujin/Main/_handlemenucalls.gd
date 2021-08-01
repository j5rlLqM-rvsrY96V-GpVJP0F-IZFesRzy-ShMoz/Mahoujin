extends Control

func _on_Link():
	var t : Thread = Thread.new()
	if t.start(OS, "shell_open", "https://github.com/NGnius/rcbup") != OK:
		OS.set_clipboard("https://github.com/NGnius/rcbup")
	#OS.shell_open("https://github.com/NGnius/rcbup")
	

func _on_Back():
	var anim = $"../../Menu/Anim"
	anim.play_backwards("Select")
# warning-ignore:return_value_discarded
	anim.connect("animation_finished", self, "call_remove")
	

func call_remove(_a : String = ""):
	queue_free()
	

func _on_New():
	var c : Dictionary = {
		"Push": 1,
		"Pull": 1,
		"Snap": 1,
		"Scale": 1,
		"Nodes": [],
		"Connections": [],
		"Snaps": []
	}
	$"../.."._set_val(c)


func _ready():
	
	$Back.text = tr("KEY_BACK")
	if get_node_or_null("Loader/New") != null:
		$Loader/New.text = tr("KEY_NEW")
		$Text.text = tr("KEY_TEXT")
	elif get_node_or_null("Link") != null:
		$Text.text = tr("KEY_BOBOTEXT")
	else:
		$Text.text = tr("KEY_ABOUT")
