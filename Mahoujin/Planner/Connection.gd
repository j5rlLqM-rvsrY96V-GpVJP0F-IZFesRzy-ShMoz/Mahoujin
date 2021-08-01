extends Node

export onready var right = $"."
export onready var left = $"."

func update(lr = left.rect_position, rr = right.rect_position):
	$Graphical.clear_points()
	$Graphical.add_point(rr)
	$Graphical.add_point(lr)
	var c = (rr + lr - $LineEdit.rect_size)/2
	$LineEdit.rect_position = c + Vector2(sin(rr.angle_to_point(lr))*$LineEdit.rect_size.x*0.6, 
										 -cos(rr.angle_to_point(lr))*$LineEdit.rect_size.y)
	$ColorPicker.rect_position = $LineEdit.rect_position + Vector2($LineEdit.rect_size.x+2,0)

func remove():
	right.consleft += 1
	left.consleft += 1
	queue_free()

func _on_colour(c):
	$Graphical.default_color = c

func _on_focus():
	if Input.is_action_pressed("ui_cancel"):
		remove()
