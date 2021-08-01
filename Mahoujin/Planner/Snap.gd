extends Control

export var radius : float = 1.0

func update():
	$Graphical.rect_scale = Vector2(radius, radius)
	$Radius.rect_position = Vector2(256*radius+10, -11)
	

func remove():
	queue_free()

func _on_action():
	if Input.is_action_pressed("ui_cancel"):
		remove()


func _on_Radius(r):
	r = float(r)
	if r > 0.09 and r <= 4:
		radius = r
		update()
	else:
		$Radius.text = str(radius)
