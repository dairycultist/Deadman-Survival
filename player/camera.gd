extends Camera3D

# screen space bounding box
func get_item_ssbb(item: Item) -> Rect2:
	
	var aabb: AABB = item.mesh().get_aabb()
	var screen_points := []
	
	for i in range(8):
		screen_points.append(
			unproject_position(          # project into screenspace
				item.to_global(          # put into global space
					aabb.get_endpoint(i) # local space AABB corner
				)
			)
		)

	# fnd the bounds of the final screen space bounding box
	var min_x: float =  INF
	var max_x: float = -INF
	var min_y: float =  INF
	var max_y: float = -INF

	for p in screen_points:
		if p.x < min_x:
			min_x = p.x
		elif p.x > max_x:
			max_x = p.x
		if p.y < min_y:
			min_y = p.y
		elif p.y > max_y:
			max_y = p.y

	return Rect2(Vector2(min_x, min_y), Vector2(max_x - min_x, max_y - min_y))
