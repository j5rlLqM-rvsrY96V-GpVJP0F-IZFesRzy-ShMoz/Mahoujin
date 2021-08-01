extends Control

var step : int = 1000000
export var c : Vector2 = Vector2.ZERO
export var id : int
export var consleft : int = INF

func calc_vector():
	
	#Get the closest element's position
	var ch : Vector2 = Vector2.INF
	for i in $"..".get_children():
		if i != self:
			if i.rect_position.distance_squared_to(rect_position) < ch.distance_squared_to(rect_position):
				ch = i.rect_position
	
	#Calculate vector change
	if ch != Vector2.INF:
		var v : Vector2 = rect_position - ch
		var d : float = rect_position.distance_to(ch)
		if d < 390*$"../../..".push:
			return v*step/d/d/d
	return Vector2.ZERO
