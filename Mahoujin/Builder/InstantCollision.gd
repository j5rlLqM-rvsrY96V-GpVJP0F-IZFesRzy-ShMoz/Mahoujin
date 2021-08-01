#extends CollisionObject
class_name InstantCollision

#As of current, using this causes crashes.

static func is_area_colliding(area : Area):
	
	var space : PhysicsDirectSpaceState = 	PhysicsServer.space_get_direct_state(
											PhysicsServer.area_get_space(area.get_rid()))
	var query : PhysicsShapeQueryParameters = PhysicsShapeQueryParameters.new()
	query.collide_with_bodies = false
	query.collide_with_areas = true
	query.collision_mask = area.collision_mask
	var shapecount : int = PhysicsServer.area_get_shape_count(area.get_rid())
	for shapeidx in shapecount:
		query.shape_rid = PhysicsServer.area_get_shape(area.get_rid(), shapeidx)
		var re : Array = space.intersect_shape(query, shapecount+1)
		for r in re:
			if r['collider'] == area:
				continue
			return true
	return false

static func get_overlapping_areas(area : Area, maxpershape : int = 64):
	#Resource intensive. Try to avoid calling this as much as possible.
	
	var arearid : RID = area.get_rid()
	var space : PhysicsDirectSpaceState = 	PhysicsServer.space_get_direct_state(
											PhysicsServer.area_get_space(arearid))
	var query : PhysicsShapeQueryParameters = PhysicsShapeQueryParameters.new()
	query.collide_with_bodies = false
	query.collide_with_areas = true
	query.collision_mask = area.collision_mask
	
	var out : Array = []
	for shapeidx in PhysicsServer.area_get_shape_count(arearid):
		var shaperid : RID = PhysicsServer.area_get_shape(arearid, shapeidx)
		query.shape_rid = shaperid
		for insshape in space.intersect_shape(query, maxpershape):
			out.append(insshape['collider'])
		
	return out
