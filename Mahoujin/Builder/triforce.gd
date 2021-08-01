extends "res://cubeconnections.gd"

const try_cubes : Dictionary = {
	557016830:  [[Vector3( 0, 0, 0), Vector3(-1, 0, 0)]],#, [Vector3(0, 0, 0), Vector3(0, 0, 1)]],
	1538778047: [[Vector3( 0, 0, 0), Vector3( 0, 0, 1)]],#, [Vector3(0, 0, 0), Vector3(0, 0,-1)]],
	1818686721: [[Vector3( 0, 2, 0), Vector3( 0, 1, 0)]],
	1312806203: [[Vector3( 0, 1, 0), Vector3( 0, 1, 0)]],
	3489647384: [[Vector3( 0, 4, 0), Vector3( 0, 1, 0)]],
	2454932271: [[Vector3( 2, 2, 0), Vector3( 1, 0, 0)]],
	3568811832: [[Vector3( 1, 1, 0), Vector3( 1, 0, 0)]],
	394503911:  [[Vector3( 2, 2, 0), Vector3( 0, 1, 0)]],
	1316425218: [[Vector3( 1, 1, 0), Vector3( 0, 1, 0)]],
	3705632066: [[Vector3( 2, 2,-2), Vector3( 0, 1, 0)]],
	651695911:  [[Vector3( 2, 0, 0), Vector3( 1, 0, 0)], [Vector3(0, 2, 0), Vector3(-1, 0, 0)]],
	4265819694: [[Vector3( 2, 0, 0), Vector3( 0,-1, 0)]],
	1319987665: [[Vector3( 1, 1,-1), Vector3( 0, 1, 0)]],
	3923036903: [[Vector3(-1, 1,-1), Vector3( 0, 1, 0)]],
} # This dictionary intentionally has less connecions than the parts actually have. This greatly improves performance.
const try_rots : Dictionary = {
	557016830:  4, 1538778047: 1,
	1818686721: 1, 1312806203: 1, 3489647384: 1,
	2454932271: 4, 3568811832: 4, 394503911:  4,
	1316425218: 4, 3705632066: 4, 651695911:  4,
	4265819694: 4, 1319987665: 4, 3923036903: 4}
const tridir : Dictionary = {
	0:  Vector3(    0,    0,    0),		1:  Vector3(    0,    0, PI/2),
	2:  Vector3(    0,    0,   PI),		3:  Vector3(    0,    0,-PI/2),
	4:  Vector3(    0, PI/2,    0),		5:  Vector3( PI/2,    0, PI/2),
	6:  Vector3(    0,-PI/2,-PI/2),		7:  Vector3(-PI/2,    0,-PI/2),
	8:  Vector3(-PI/2,    0, PI/2),		9:  Vector3( PI/2,    0,-PI/2),
	10: Vector3(    0,-PI/2, PI/2),		11: Vector3(    0, PI/2,-PI/2),
	12: Vector3(    0, PI/2, PI/2),		13: Vector3(    0,-PI/2,   PI),
	14: Vector3(    0,   PI,    0),		15: Vector3(    0,   PI,-PI/2),
	16: Vector3(    0,   PI,   PI),		17: Vector3(   PI,    0,-PI/2),
	18: Vector3(    0,-PI/2,    0),		19: Vector3(    0, PI/2,   PI),
	20: Vector3( PI/2,    0,    0),		21: Vector3(-PI/2,    0,   PI),
	22: Vector3(-PI/2,    0,    0),		23: Vector3( PI/2,    0,   PI)}
const precomp_rots : Dictionary = {
	Vector3( 0, 0, 1): [5, 9, 20, 23,14],
	Vector3( 0, 0,-1): [7, 8, 21, 22, 0],
	Vector3( 0, 1, 0): [0, 4, 14, 18,10],
	Vector3( 0,-1, 0): [2,13, 16, 19, 6],
	Vector3( 1, 0, 0): [3, 6, 11, 15, 8],
	Vector3(-1, 0, 0): [1,10, 12, 17, 4],
} #fromdir: [orth indexes*]  *last is for edges only
const check_cubes : Array = [
	557016830, 1818686721, 1312806203, 3489647384, 2454932271, 3568811832, 
	394503911, 1316425218, 3705632066, 651695911,  4265819694, 1319987665, 3923036903
] #Note: Omitts edges as rot is different.
const edges_opt : Dictionary = {
	14:15, 15:16, 16:17, 17:-1,   10:11, 11:20, 20:21, 21:-1,    8: 9,  9:18, 18:19, 19:-1,
	 0: 1,  1: 2,  2: 3,  3:-1,    6:12, 12:22, 22:23, 23:-1,    4: 5,  5: 7,  7:13, 13:-1
	}
const corners_opt : Dictionary = {
	5: 9, 9: 20, 20: 23, 23: 5,
	7: 8, 8: 21, 21: 22, 22: 7,
	0: 4, 4: 14, 14: 18, 18: 0,
	2:13,13: 16, 16: 19, 19: 2,
	3: 6, 6: 11, 11: 15, 15: 3,
	1:10,10: 12, 12: 17, 17: 1
} #FIXME: These numbers are guesses. The order of each line may need to be adjusted.

var try_cols : bool = true
var ram_target : int = 1073741824 # 1GB
var thread_count : int = 4
var threads : Array = []
var to_validate : Array = []
var on_hold : Array = []
var do_cols : int = 0
var ticks : int = 0
var bot_data : Array = []
var offset : int = 64
var to_rem : Array = []

onready var builder : Spatial = $"../Builder"

static func rot_v3(vec : Vector3, by_i : int):
	var by : Vector3 = tridir[by_i]
	vec = vec.rotated(Vector3.UP,   by.y)
	vec = vec.rotated(Vector3.RIGHT,by.x)
	vec = vec.rotated(Vector3.BACK, by.z)
	return vec.round()

func get_c_points(part : int, pos : Vector3 = Vector3.ZERO, rot : int = 0):
	var out : Array = []
	for c in all_connections[part]:
		out.append([ pos+rot_v3(c[0], rot), rot_v3(c[1], rot) ])
	return out

static func get_tri_c_points(part : int, pos : Vector3 = Vector3.ZERO, rot : int = 0):
	var out : Array = []
	for i in try_cubes[part]:
		out.append([ pos+rot_v3(i[0], rot), rot_v3(i[1], rot) ])
	return out

static func get_areas(n : Spatial):
	var out : Array = []
	if n is Area:
		n.collision_layer = 2
		out = [n]
	for child in n.get_children():
		out.append_array(get_areas(child))
	return out

func check_placement(part : int, pos : Vector3, rot : int):
	return true
	#I thought this would be a good idea initially...
	
# warning-ignore:unreachable_code
	var p : Spatial = builder.add_part(part, pos, rot, true)
	var areas : Array = get_areas(p)
	add_child(p)
	for area in areas:
		#I did totally not create this class just for this
		#Something seems to carsh tho. 
		if InstantCollision.is_area_colliding(area):
			to_rem.append(p)
			return false
	to_rem.append(p)
	return true

const precomp_check_vals : Dictionary = {
	Vector3( 0, 0, 1):			 [[557016830 , [5, 9, 20, 23]], [1538778047, [14]],
	[1818686721, [5]],			  [1312806203, [5]],			[3489647384, [5]],
	[2454932271, [5, 9, 20, 23]], [3568811832, [5, 9, 20, 23]], [394503911 , [5, 9, 20, 23]],
	[1316425218, [5, 9, 20, 23]], [3705632066, [5, 9, 20, 23]], [651695911 , [5, 9, 20, 23]],
	[4265819694, [5, 9, 20, 23]], [1319987665, [5, 9, 20, 23]], [3923036903, [5, 9, 20, 23]]],
	Vector3( 0, 0,-1):			  [[557016830, [7, 8, 21, 22]], [1538778047, [0]],
	[1818686721, [7]],			  [1312806203, [7]],			[3489647384, [7]],
	[2454932271, [7, 8, 21, 22]], [3568811832, [7, 8, 21, 22]], [394503911 , [7, 8, 21, 22]],
	[1316425218, [7, 8, 21, 22]], [3705632066, [7, 8, 21, 22]], [651695911 , [7, 8, 21, 22]],
	[4265819694, [7, 8, 21, 22]], [1319987665, [7, 8, 21, 22]], [3923036903, [7, 8, 21, 22]]],
	Vector3( 0, 1, 0):			 [[557016830 , [0, 4, 14, 18]], [1538778047, [10]],
	[1818686721, [0]],			  [1312806203, [0]],			[3489647384, [0]],
	[2454932271, [0, 4, 14, 18]], [3568811832, [0, 4, 14, 18]], [394503911 , [0, 4, 14, 18]],
	[1316425218, [0, 4, 14, 18]], [3705632066, [0, 4, 14, 18]], [651695911 , [0, 4, 14, 18]],
	[4265819694, [0, 4, 14, 18]], [1319987665, [0, 4, 14, 18]], [3923036903, [0, 4, 14, 18]]],
	Vector3( 0,-1, 0):			  [[557016830, [2,13, 16, 19]], [1538778047, [6]],
	[1818686721, [2]],			  [1312806203, [2]],			[3489647384, [2]],
	[2454932271, [2,13, 16, 19]], [3568811832, [2,13, 16, 19]], [394503911 , [2,13, 16, 19]],
	[1316425218, [2,13, 16, 19]], [3705632066, [2,13, 16, 19]], [651695911 , [2,13, 16, 19]],
	[4265819694, [2,13, 16, 19]], [1319987665, [2,13, 16, 19]], [3923036903, [2,13, 16, 19]]],
	Vector3( 1, 0, 0):			 [[557016830 , [3, 6, 11, 15]], [1538778047, [8]],
	[1818686721, [3]],			  [1312806203, [3]],			[3489647384, [3]],
	[2454932271, [3, 6, 11, 15]], [3568811832, [3, 6, 11, 15]], [394503911 , [3, 6, 11, 15]],
	[1316425218, [3, 6, 11, 15]], [3705632066, [3, 6, 11, 15]], [651695911 , [3, 6, 11, 15]],
	[4265819694, [3, 6, 11, 15]], [1319987665, [3, 6, 11, 15]], [3923036903, [3, 6, 11, 15]]],
	Vector3(-1, 0, 0):			 [[557016830 , [1,10, 12, 17]], [1538778047, [4]],
	[1818686721, [1]],			  [1312806203, [1]],			[3489647384, [1]],
	[2454932271, [1,10, 12, 17]], [3568811832, [1,10, 12, 17]], [394503911 , [1,10, 12, 17]],
	[1316425218, [1,10, 12, 17]], [3705632066, [1,10, 12, 17]], [651695911 , [1,10, 12, 17]],
	[4265819694, [1,10, 12, 17]], [1319987665, [1,10, 12, 17]], [3923036903, [1,10, 12, 17]]]}
func check_loc(pos : Vector3, fromdir : Vector3):
	return precomp_check_vals[fromdir]
	
	#If you'd get the check_placement function to work, use this
# warning-ignore:unreachable_code
	var rots : Array = precomp_rots[fromdir]
	var out : Array = []
	
	if check_placement(1538778047, pos, rots[4]):
		out.append([1538778047, [rots[4] ]])
	for cube in check_cubes:
		var try : Array = [cube, []]
		for r in try_rots[cube]:
			if check_placement(cube, pos, rots[r]):
				try[1].append(rots[r])
		if try[1] != []:
			out.append(try)
	return out
		
#		#Old code, no precompute
#	for cube in try_cubes:
#		var try : Array = [cube, []]
#		for rot in dir:
#			if check_placement(cube, pos, rot):
#				var halt : bool = false
#				for c in get_tri_c_points(cube, pos, rot):
#					if c[1]+fromdir == Vector3.ZERO and c[0]+c[1] == pos-fromdir:
#							try[1].append(rot)
#							if len(try[1]) >= try_rots[cube]:
#								halt = true
#							break
#				if halt:
#					break
#		if len(try[1]) > 0:
#			out.append(try)
#	return out

func try_path(from : Vector3, fromdir : Vector3, endpoints : Array, length : int):
	#TODO: Optimise
	#Better algo? Less loops?
	#The time this function takes exponentially scales with 'length'
	var paths_left : Array = []
	var current_path : Array = [[from, fromdir]]
	var out : Array = []
	length += 1
	
	while true:
		var dir : Vector3 = current_path[-1][1]
		var lok : Vector3 = current_path[-1][0]+dir
		for e in endpoints:
			if lok == e[0] and e[1] == dir*-1:
				var temp : Array = []
				for i in len(current_path)-1:
					temp.append(current_path[i+1][2])
				out.append(temp)
#				current_path.pop_back()
#				dir = current_path[-1][1]
#				lok = current_path[-1][0]+dir
				break
		
		var parts : Array = precomp_check_vals[dir]#check_loc(pos+dir, dir)
		if parts != [] and len(current_path) < length:
			var temp : Array = []
			for part in parts:
				for rot in part[1]:
					for c in get_tri_c_points(part[0], lok, rot):
#						if c[0]+c[1] != pos:
						temp.append([c[0], c[1], [part[0], lok, rot]])
			paths_left.append(temp)
		else:
			current_path.pop_back()
		
		while len(paths_left[-1]) == 0:
			paths_left.pop_back()
			current_path.pop_back()
			if len(paths_left) == 0:
				return out
		
		current_path.append(paths_left[-1].pop_back())
	
	return out

func thread_path(data : Array):
	return try_path(data[0], data[1], data[2], data[3])

func try_connect(partfrom, partto, length):
	var frompoints : Array = get_c_points(partfrom[0], partfrom[1], partfrom[2])
	var topoints : Array = get_c_points(partto[0], partto[1], partto[2])
	var out : Array = []
	var used_threads : Array = []
	
	for from in len(frompoints):
		if len(threads) < thread_count and from+1 < len(frompoints):
			var t : Thread = Thread.new()
			threads.append(t)
			var re : int = t.start(self, "thread_path", [frompoints[from][0], frompoints[from][1], topoints, length])
			if re != OK:
				print("An error occured while creating a thread.")
			else:
				used_threads.append(len(threads)-1)
		else:
			var paths : Array = try_path(frompoints[from][0], frompoints[from][1], topoints, length)
			out.append_array(paths)
	
	used_threads.invert()
	for t in used_threads:
		out.append_array(threads[t].wait_to_finish())
		#threads[t].free()
		threads.remove(t)
	
	return out

func expand_data(bot : Array, data : Array):
	var out = []
	for conn in data:
		out.append([[conn[0]], [conn[1]], conn[2]])
	
	for part in len(bot):
		for c in len(data):
			if data[c][0] == bot[part][0]:
				out[c][0].append([ bot[part][1], bot[part][2] ])
			if data[c][1] == bot[part][0]:
				out[c][1].append([ bot[part][1], bot[part][2] ])
	return out

func work(c : Array):
	var possibilities = []
	for id1 in len(c[0])-1:
		id1 += 1
		for id2 in len(c[1])-1:
			id2 += 1
			var re = try_connect(
				[c[0][0], c[0][id1][0], c[0][id1][1]], 
				[c[1][0], c[1][id2][0], c[1][id2][1]], 
				c[2]) 
			if re != []:
				possibilities.append_array(re)
	
	return [c[0][0], c[1][0], possibilities]

func clean_macro(bot : Array):
	var to_remove = []
	to_remove.append_array(chassis.keys())
	to_remove.append_array(cosmetic.keys())
	var part = len(bot)
	while part > 0:
		part -= 1
		for r in to_remove:
			if r == bot[part][0]:
				bot.remove(part)
				break
	return bot

func tryforce(bot : Array, data : Array):
	if len(data) == 0:
		return []
	
	bot = clean_macro(bot)
	data = expand_data(bot, data)
	
	var out = []
	if OS.can_use_threads() and thread_count > 1:
		if thread_count <= len(data):
			for i in thread_count:
				var t : Thread = Thread.new()
				threads.append(t)
			
# warning-ignore:integer_division
			for i in len(data)/(thread_count+1):
				i *= (thread_count+1)
				for thread in thread_count:
					var t : int = threads[thread].start(self, "work", [data[i+thread]])
					if t != OK:
						print("An error occured while creating a thread.")
				out.append(work(i))
				
				for thread in thread_count:
					var re = threads[thread].wait_to_finish()
					out.append(re)
		else:
			for i in len(data)-1:
				var t : Thread = Thread.new()
				threads.append(t)
				var re : int = t.start(self, "work", [data[i]])
				if re != OK:
					print("An error occured while creating a thread.")
			out.append(work(data[-1]))
			
			for i in len(data)-1:
				var re = threads[i].wait_to_finish()
				out.append(re)
	else:
		for i in data:
			var re = work(i)
			out.append(re)
	
	for t in threads:
		threads.remove(-1)
	
	#Validate collision
	if try_cols:
		bot_data = bot
		validate_paths(out)
	else: return out

func validate_paths(data : Array):
	for conn in data:
		offset += 32
		var paths : Array = []
		var conn_a : Array = []
		var used : Array = [] 
		var bot : Spatial = builder._build(bot_data, true)
		bot.transform.origin = Vector3(offset,0,0)
		add_child(bot)
		for _i in len(conn[2]):
			var path : Array = conn[2].pop_back()
			used.append(path)
			var p_ : Array = []
			var p_areas : Array = []
			for part in path:
				var p : Spatial = builder.add_part(part[0], part[1], part[2], true)
				p_areas.append(get_areas(p))
				bot.add_child(p)
				p_.append(p)
			paths.append(p_)
			conn_a.append(p_areas)
			if OS.get_static_memory_usage() > ram_target: #1073741824 = 1GB, 1048576 = 1MB, 2147483648 = 2GB
				to_validate.append([conn[0], conn[1], used, paths, conn_a, bot])
				on_hold = data #Arrays are by reference
				return
		to_validate.append([conn[0], conn[1], used, paths, conn_a, bot])

func val_paths(val : Array):
	if len(val[2]) != len(val[3]) or len(val[3]) != len(val[4]):
		print("Length mismatch")
		breakpoint
	
	var to_remove : Array = []
	for path in len(val[2]):
		var halt : bool = false
		
		for part in len(val[2][path]):
			for area in val[4][path][part]:
				if area.get_overlapping_areas() != []:
						
					#Means path is not valid.
					
					#Optimisational trick
					if val[2][path][part][0] == 1538778047:
						var rot : int = edges_opt[val[2][path][part][2]]
						if rot != -1:
							var p : Array = val[2][path].duplicate()
							p[part][2] = rot
							for i in len(on_hold):
								if on_hold[i][0] == val[0] and on_hold[i][1] == val[1]:
									on_hold[i][2].append(p)
									rot = -1
									break
							if rot != -1:
								on_hold.append([val[0], val[1], [p]])
					elif val[2][path][part][0] == 557016830:
						if len(val[2][path][part]) < 4:
							var p : Array = val[2][path].duplicate()
							var rot : int = corners_opt[val[2][path][part][2]]
							p[part][2] = rot
							p[part].append(false)
							for i in len(on_hold):
								if on_hold[i][0] == val[0] and on_hold[i][1] == val[1]:
									on_hold[i][2].append(p)
									rot = -1
									break
							if rot != -1:
								on_hold.append([val[0], val[1], [p]])
					halt = true
					break
				if halt:
					break
			if halt:
				break
		#Free the test path parts
		for part in val[3][path]:
			part.queue_free()
		val[5].queue_free()
		if halt:
			#Remove the invalid path from data
			to_remove.append(path)
	#Clear out the invalid data
	#and pass the data to the tree
	to_remove.invert()
	for i in to_remove:
		val[2].remove(i)
	$"..".add_to_tree([[val[0], val[1], val[2]]])
	

func _ready():
# warning-ignore:return_value_discarded
	get_tree().connect("physics_frame", self, "_phy_step", [])
	
#	for fromdir in precomp_rots:
#		var out : Array = []
#		for cube in [1538778047]:
#			var try : Array = [cube, []]
#			for rot in tridir:
#				if check_placement(cube, Vector3.ZERO, rot):
#					var halt : bool = false
#					for c in get_tri_c_points(cube, Vector3.ZERO, rot):
#						if c[1]+fromdir == Vector3.ZERO and c[0]+c[1] == -fromdir:
#								try[1].append(rot)
#								if len(try[1]) >= try_rots[cube]:
#									halt = true
#								break
#					if halt:
#						break
#			if len(try[1]) > 0:
#				out.append(try)
#		print(out)

func _physics_process(_delta):
	for r in to_rem:
		r.queue_free()
	if to_validate != []:
		do_cols += 1
	if on_hold != []:
		ticks += 1
		if ticks > 30: #Give it some time to process the queue and clear out the RAM
			validate_paths(on_hold)
			ticks = 0
			
			var to_remove : Array = []
			for i in len(on_hold):
				if on_hold[i][2] == []:
					to_remove.append(i)
			to_remove.invert()
			for i in to_remove:
				on_hold.remove(i)


func _phy_step():
	if do_cols > 2:
		var used_threads : Array = []
		for val in len(to_validate):
			if len(threads) < thread_count and val+1 < len(to_validate):
				var t : Thread = Thread.new()
				threads.append(t)
				var re : int = t.start(self, "val_paths", [to_validate[val]])
				if re != OK:
					print("An error occured while creating a thread.")
				else:
					used_threads.append(len(threads)-1)
			else:
				val_paths(to_validate[val])
		
		used_threads.invert()
		for t in used_threads:
			threads[t].wait_to_finish()
			threads.remove(t)
			
		to_validate = []
		do_cols = 0
