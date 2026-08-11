extends Node2D
class_name InteractiveManager

@onready var main = get_parent()

func _is_cell_completely_empty(grid_pos: Vector2i, ignore_platforms: bool = false) -> bool:
	var player_pos = main.layer_floor.local_to_map(main.sprite_player.global_position)
	var arrival_pos = main.layer_floor.local_to_map(main.sprite_arrival.global_position)
	if grid_pos == player_pos or grid_pos == arrival_pos:
		return false
	if main.layer_floor.get_cell_source_id(grid_pos) != -1: return false
	if main.layer_wall.get_cell_source_id(grid_pos) != -1: return false
	if main.layer_ice.get_cell_source_id(grid_pos) != -1: return false
	if main.spawned_fragiles.has(grid_pos): return false
	if main.spawned_hiddens.has(grid_pos): return false
	if not ignore_platforms and main.spawned_platforms.has(grid_pos): return false
	if _get_door_at(grid_pos) != null: return false
	return true

func _get_platform_at(grid_pos: Vector2i) -> Node2D:
	for plat in main.spawned_platforms.values():
		if is_instance_valid(plat):
			var plat_area = plat.get_node_or_null("New_Platform")
			if plat_area != null and grid_pos in plat_area.way:
				return plat
	return null

func can_place_door_or_key(tile_pos: Vector2i) -> bool:
	if main.layer_floor == null or main.layer_floor.get_cell_source_id(tile_pos) == -1:
		return false
	var p_pos = main.layer_floor.local_to_map(main.sprite_player.global_position) if main.player == null else main.layer_floor.local_to_map(main.player.global_position)
	if p_pos == tile_pos:
		return false
	var a_pos = main.layer_floor.local_to_map(main.sprite_arrival.global_position) if main.arrival_instance == null else main.layer_floor.local_to_map(main.arrival_instance.global_position)
	if a_pos == tile_pos:
		return false
	if _get_platform_at(tile_pos) != null:
		return false
	for door in get_tree().get_nodes_in_group("Doors"):
		if door != main.active_configured_door or not main.is_dragging_door:
			if main.layer_floor.local_to_map(door.global_position) == tile_pos:
				return false
		var keys_container = door.get_node_or_null("Keys")
		if keys_container:
			for key in keys_container.get_children():
				if key != main.active_configured_key or not main.is_dragging_key:
					if main.layer_floor.local_to_map(key.global_position) == tile_pos:
						return false
	return true

func get_nearest_valid_tile(start_tile: Vector2i) -> Vector2i:
	var max_radius: = 10
	for r in range(1, max_radius):
		for x in range(-r, r + 1):
			for y in range(-r, r + 1):
				if abs(x) == r or abs(y) == r:
					var check_tile = start_tile + Vector2i(x, y)
					if can_place_door_or_key(check_tile):
						return check_tile
	return start_tile

func _get_door_at(grid_pos: Vector2i) -> Node2D:
	for door in get_tree().get_nodes_in_group("Doors"):
		if main.layer_floor.local_to_map(door.global_position) == grid_pos:
			return door
	return null

func _get_key_at(grid_pos: Vector2i) -> Array:
	for door in get_tree().get_nodes_in_group("Doors"):
		var keys_container = door.get_node_or_null("Keys")
		if keys_container:
			for key in keys_container.get_children():
				if main.layer_floor.local_to_map(key.global_position) == grid_pos:
					return [door, key]
	return []

func update_door_keys_array(door: New_Door) -> void:
	door.debug_keys_coords.clear()
	var keys_container = door.get_node_or_null("Keys")
	if keys_container:
		for key in keys_container.get_children():
			if key.is_queued_for_deletion():
				continue
			var key_tile = main.layer_floor.local_to_map(key.global_position)
			door.debug_keys_coords.append(key_tile)
	door.update_key_display()

func _spawn_new_door(grid_pos: Vector2i) -> void:
	var new_door = main.DOOR_SCENE.instantiate()
	main.map_node.add_child(new_door)
	new_door.global_position = main.layer_floor.map_to_local(grid_pos)
	var nearest_tile = get_nearest_valid_tile(grid_pos)
	new_door.generate_keys([nearest_tile])
	main.active_configured_door = new_door
	main.active_configured_key = null
	if main.selection:
		main.selection.global_position = main.layer_floor.map_to_local(grid_pos) - Vector2(8, 8)
		main.selection.visible = true

func _spawn_new_platform(grid_pos: Vector2i) -> void:
	var plat_way_inst = main.PLATFORM_SCENE.instantiate()
	plat_way_inst.position = Vector2.ZERO 
	var platform_area = plat_way_inst.get_node("New_Platform")
	platform_area.position = main.layer_floor.map_to_local(grid_pos)
	main.node_platforms.add_child(plat_way_inst) 
	main.spawned_platforms[grid_pos] = plat_way_inst
	var initial_way: Array[Vector2i] = [grid_pos]
	platform_area.set_way(initial_way)
	_start_configuring_platform(plat_way_inst, grid_pos)

func _handle_interactive_click(grid_pos: Vector2i, is_just_clicked: bool) -> void:
	if is_just_clicked and main.ui_layer.get("is_linking_doors") and main.ui_layer.is_linking_doors:
		var clicked_plat = _get_platform_at(grid_pos)
		if clicked_plat != null:
			if is_instance_valid(main.active_configured_door):
				var plat_area = clicked_plat.get_node("New_Platform")
				var door_pos = main.layer_floor.local_to_map(main.active_configured_door.global_position)
				if plat_area.is_linked_to_door and plat_area.linked_door_pos == door_pos:
					plat_area.is_linked_to_door = false
					plat_area.linked_door_pos = Vector2i.ZERO
				else:
					plat_area.is_linked_to_door = true
					plat_area.linked_door_pos = door_pos
			return
		elif _get_door_at(grid_pos) == null and _get_key_at(grid_pos).is_empty():
			return
	match main.current_interactive_type:
		main.InteractiveType.PLATFORM:
			if is_just_clicked:
				var clicked_plat = _get_platform_at(grid_pos)
				if main.active_configured_platform != null and clicked_plat == main.active_configured_platform:
					var plat_area = main.active_configured_platform.get_node("New_Platform")
					if grid_pos == plat_area.way[plat_area.start_index]:
						main.is_dragging_platform = true
						main.dragged_platform = plat_area
						main.platform_drag_start_pos = plat_area.global_position
						if main.selection != null:
							main.selection.visible = false
						return
				if clicked_plat != null and clicked_plat != main.active_configured_platform:
					_start_configuring_platform(clicked_plat, grid_pos)
					return
				if main.active_configured_platform == null and _is_cell_completely_empty(grid_pos):
					_spawn_new_platform(grid_pos)
					return
			if main.active_configured_platform != null:
				var has_handled_drag = _try_add_to_platform_path(grid_pos)
				if not has_handled_drag and is_just_clicked:
					_stop_configuring_interactive()
					_handle_interactive_click(grid_pos, is_just_clicked)
		main.InteractiveType.DOOR:
			if is_just_clicked:
				var clicked_door = _get_door_at(grid_pos)
				var clicked_key_info = _get_key_at(grid_pos)
				if not clicked_key_info.is_empty():
					if main.ui_layer.has_method("desactiver_door_linker"):
						main.ui_layer.desactiver_door_linker()
					main.active_configured_door = clicked_key_info[0]
					main.active_configured_key = clicked_key_info[1]
					main.is_dragging_key = true
					main.key_drag_start_pos = main.active_configured_key.global_position
					if main.selection:
						main.selection.global_position = main.layer_floor.map_to_local(grid_pos) - Vector2(8, 8)
						main.selection.visible = true
					return
				if clicked_door != null:
					if main.active_configured_door != clicked_door:
						if main.ui_layer.has_method("desactiver_door_linker"):
							main.ui_layer.desactiver_door_linker()
					main.door_was_already_selected = (main.active_configured_door == clicked_door)
					main.active_configured_door = clicked_door
					main.active_configured_key = null
					main.is_dragging_door = true
					main.door_drag_start_pos = clicked_door.global_position
					if main.selection:
						main.selection.global_position = main.layer_floor.map_to_local(grid_pos) - Vector2(8, 8)
						main.selection.visible = true
					return
				if can_place_door_or_key(grid_pos):
					if main.ui_layer.has_method("desactiver_door_linker"):
						main.ui_layer.desactiver_door_linker()
					_spawn_new_door(grid_pos)
					return
		main.InteractiveType.PORTAL:
			pass

func handle_drag_input(event: InputEvent) -> void:
	if main.is_dragging_player:
		if event is InputEventMouseMotion:
			main.sprite_player.global_position = main.get_global_mouse_position()
			main.get_viewport().set_input_as_handled()
		elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
			if not event.pressed:
				main.is_dragging_player = false
				snap_player_to_grid()
				main.get_viewport().set_input_as_handled()
	if main.is_dragging_arrival:
		if event is InputEventMouseMotion:
			main.sprite_arrival.global_position = main.get_global_mouse_position()
			main.get_viewport().set_input_as_handled()
		elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
			if not event.pressed:
				main.is_dragging_arrival = false
				snap_arrival_to_grid()
				main.get_viewport().set_input_as_handled()
	if main.is_dragging_platform and is_instance_valid(main.dragged_platform):
		if event is InputEventMouseMotion:
			main.dragged_platform.global_position = main.get_global_mouse_position()
			main.get_viewport().set_input_as_handled()
		elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
			if not event.pressed:
				main.is_dragging_platform = false
				var drop_grid_pos = main.layer_floor.local_to_map(main.dragged_platform.global_position)
				if not main.dragged_platform.try_set_start_pos(drop_grid_pos):
					main.dragged_platform.global_position = main.platform_drag_start_pos
				else:
					if main.selection != null and main.active_configured_platform == main.dragged_platform.get_parent():
						main.selection.global_position = main.layer_floor.map_to_local(drop_grid_pos) - Vector2(8, 8)
				if main.active_configured_platform == main.dragged_platform.get_parent():
					main.selection.visible = true
				main.dragged_platform = null
				main.get_viewport().set_input_as_handled()
				
	if main.is_dragging_door and is_instance_valid(main.active_configured_door):
		if event is InputEventMouseMotion:
			main.active_configured_door.global_position = main.get_global_mouse_position()
			main.get_viewport().set_input_as_handled()
		elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
			if not event.pressed:
				var drop_grid_pos = main.layer_floor.local_to_map(main.active_configured_door.global_position)
				var distance_moved = (main.active_configured_door.global_position - main.door_drag_start_pos).length()
				if can_place_door_or_key(drop_grid_pos):
					main.active_configured_door.global_position = main.layer_floor.map_to_local(drop_grid_pos)
				else:
					main.active_configured_door.global_position = main.door_drag_start_pos
					drop_grid_pos = main.layer_floor.local_to_map(main.door_drag_start_pos)
				main.is_dragging_door = false
				if distance_moved < 5.0 and main.door_was_already_selected:
					var nearest_tile = get_nearest_valid_tile(drop_grid_pos)
					main.active_configured_door.generate_one_key(nearest_tile)
				if main.selection:
					main.selection.global_position = main.active_configured_door.global_position - Vector2(8, 8)
				main.get_viewport().set_input_as_handled()
				
	if main.is_dragging_key and is_instance_valid(main.active_configured_key):
		if event is InputEventMouseMotion:
			main.active_configured_key.global_position = main.get_global_mouse_position()
			main.get_viewport().set_input_as_handled()
		elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
			if not event.pressed:
				var drop_grid_pos = main.layer_floor.local_to_map(main.active_configured_key.global_position)
				
				# LA CORRECTION : Pareil ici, avant d'arrêter le drag
				if can_place_door_or_key(drop_grid_pos):
					main.active_configured_key.global_position = main.layer_floor.map_to_local(drop_grid_pos)
				else:
					main.active_configured_key.global_position = main.key_drag_start_pos
					
				main.is_dragging_key = false
				
				if main.selection:
					main.selection.global_position = main.active_configured_key.global_position - Vector2(8, 8)
				update_door_keys_array(main.active_configured_door)
				main.get_viewport().set_input_as_handled()

func _handle_interactive_erase(grid_pos: Vector2i) -> void:
	match main.current_interactive_type:
		main.InteractiveType.PLATFORM:
			var plat = _get_platform_at(grid_pos)
			if plat != null:
				var platform_area = plat.get_node("New_Platform")
				var current_way = platform_area.way.duplicate()
				var index = current_way.find(grid_pos)
				if index != -1:
					if index == platform_area.start_index:
						if main.active_configured_platform == plat:
							_stop_configuring_interactive()
						var key_to_remove = null
						for k in main.spawned_platforms:
							if main.spawned_platforms[k] == plat:
								key_to_remove = k
								break
						if key_to_remove != null:
							main.spawned_platforms.erase(key_to_remove)
						plat.queue_free()
						return
					if platform_area.is_looping:
						var new_way: Array[Vector2i] = []
						for i in range(1, current_way.size()):
							var w_idx = (index + i) % current_way.size()
							new_way.append(current_way[w_idx])
						var old_plat_pos = current_way[platform_area.start_index]
						current_way = new_way
						platform_area.start_index = current_way.find(old_plat_pos)
					elif index > platform_area.start_index:
						current_way.resize(index)
					elif index < platform_area.start_index:
						current_way = current_way.slice(index + 1)
						platform_area.start_index -= (index + 1)
					platform_area.is_looping = false
					platform_area.set_way(current_way)
					platform_area.reset_to_editor()
					if main.active_configured_platform != plat:
						_start_configuring_platform(plat, current_way[platform_area.start_index])
		main.InteractiveType.DOOR:
			var clicked_key_info = _get_key_at(grid_pos)
			if not clicked_key_info.is_empty():
				var door = clicked_key_info[0]
				var key = clicked_key_info[1]
				var keys_container = door.get_node_or_null("Keys")
				if keys_container and keys_container.get_child_count() > 1:
					key.queue_free()
					call_deferred("update_door_keys_array", door)
				return
				
			var clicked_door = _get_door_at(grid_pos)
			if clicked_door != null:
				if main.active_configured_door == clicked_door:
					_stop_configuring_interactive()
				clicked_door.queue_free()
		main.InteractiveType.PORTAL:
			pass

func _start_configuring_platform(plat_way_inst: Node2D, clicked_pos: Vector2i) -> void:
	main.active_configured_platform = plat_way_inst
	var platform_area = plat_way_inst.get_node("New_Platform")
	var start_cell = clicked_pos
	if not platform_area.way.is_empty():
		start_cell = platform_area.way[platform_area.start_index]
	main.selection.global_position = main.layer_floor.map_to_local(start_cell) - Vector2(8, 8) 
	main.selection.visible = true

func _try_add_to_platform_path(grid_pos: Vector2i) -> bool:
	var platform_area = main.active_configured_platform.get_node("New_Platform")
	if platform_area.is_looping: return true
	var current_way = platform_area.way.duplicate()
	if current_way.is_empty(): return true
	var front_cell = current_way.front()
	var back_cell = current_way.back()
	var diff_ends = abs(front_cell - back_cell)
	var ends_are_adjacent = (diff_ends.x == 1 and diff_ends.y == 0) or (diff_ends.x == 0 and diff_ends.y == 1)
	if grid_pos in current_way:
		if current_way.size() >= 3 and ends_are_adjacent:
			if (grid_pos == back_cell and platform_area.last_modified_end == 0) or (grid_pos == front_cell and platform_area.last_modified_end == 1):
				current_way.append(front_cell)
				platform_area.set_way(current_way)
				return true
		return true
	var diff_front = abs(grid_pos - front_cell)
	var diff_back = abs(grid_pos - back_cell)
	var adj_front = (diff_front.x == 1 and diff_front.y == 0) or (diff_front.x == 0 and diff_front.y == 1)
	var adj_back = (diff_back.x == 1 and diff_back.y == 0) or (diff_back.x == 0 and diff_back.y == 1)
	if adj_front or adj_back:
		if _get_platform_at(grid_pos) == null and _is_cell_completely_empty(grid_pos, true):
			var insert_at_back = false
			if adj_front and adj_back:
				insert_at_back = (platform_area.last_modified_end == 1)
			elif adj_back:
				insert_at_back = true
			else:
				insert_at_back = false
			if insert_at_back:
				current_way.append(grid_pos)
				platform_area.last_modified_end = 1
			else:
				current_way.push_front(grid_pos)
				platform_area.last_modified_end = 0
				platform_area.start_index += 1 
			platform_area.set_way(current_way)
		return true
	else:
		return false

func _inverse_path() -> void:
	if main.active_configured_platform != null:
		var p_area = main.active_configured_platform.get_node("New_Platform")
		p_area.reverse_path()

func _stop_configuring_interactive() -> void:
	main.active_configured_platform = null
	main.active_configured_door = null
	main.active_configured_key = null
	if main.selection != null:
		main.selection.visible = false

func snap_player_to_grid() -> void:
	var grid_pos = main.layer_floor.local_to_map(main.sprite_player.global_position)
	var arrival_pos = main.layer_floor.local_to_map(main.sprite_arrival.global_position)
	var has_floor = main.layer_floor.get_cell_source_id(grid_pos) != -1 and not main.spawned_fragiles.has(grid_pos)
	if has_floor and grid_pos != arrival_pos and _get_platform_at(grid_pos) == null:
		main.sprite_player.global_position = main.layer_floor.map_to_local(grid_pos) + Vector2(0, -2)
	else:
		main.sprite_player.global_position = main.player_drag_start_pos

func snap_arrival_to_grid() -> void:
	var grid_pos = main.layer_floor.local_to_map(main.sprite_arrival.global_position)
	var player_pos = main.layer_floor.local_to_map(main.sprite_player.global_position)
	if grid_pos != player_pos and _get_platform_at(grid_pos) == null:
		main.sprite_arrival.global_position = main.layer_floor.map_to_local(grid_pos) + Vector2(0, -2)
		if main.has_node("TileManager"):
			main.get_node("TileManager").generate_grass_under(grid_pos)
	else:
		main.sprite_arrival.global_position = main.arrival_drag_start_pos

# ==========================================
# DESSIN DES LIENS (LINKER MODE)
# ==========================================

func _ready() -> void:
	z_index = 100

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	if not main.ui_layer.get("is_linking_doors") or not main.ui_layer.is_linking_doors:
		return
	var link_color = Color(0.8, 0.2, 0.8, 0.8)
	var line_width = 3.0
	for plat in main.spawned_platforms.values():
		if is_instance_valid(plat):
			var plat_area = plat.get_node_or_null("New_Platform")
			if plat_area != null and plat_area.get("is_linked_to_door"):
				var start_pos = to_local(plat_area.global_position)
				var end_pos = Vector2.ZERO
				var should_draw = false
				if is_instance_valid(plat_area.linked_door_node):
					end_pos = to_local(plat_area.linked_door_node.global_position)
					should_draw = true
				elif plat_area.linked_door_pos != Vector2i.ZERO:
					end_pos = to_local(main.layer_floor.map_to_local(plat_area.linked_door_pos))
					should_draw = true
				if should_draw:
					draw_line(start_pos, end_pos, link_color, line_width)
					draw_circle(start_pos, 4.0, link_color)
					draw_circle(end_pos, 4.0, link_color)
