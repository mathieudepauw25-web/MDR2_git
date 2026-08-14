extends Node
class_name TileManager

@onready var main = get_parent()
var is_erasing_deco_only: bool = false

func get_source_id(layer: TileMapLayer, cell_pos: Vector2i) -> int:
	if layer == null: return -1
	return layer.get_cell_source_id(cell_pos)

func get_atlas_coords(layer: TileMapLayer, cell_pos: Vector2i) -> Vector2i:
	if layer == null: return Vector2i(-1, -1)
	return layer.get_cell_atlas_coords(cell_pos)

func get_skin_element(prefix: String, key: String, theme: String = "") -> Variant:
	if not TileSkinData.SKINS.has(main.current_skin_name): return null
	var skin = TileSkinData.SKINS[main.current_skin_name]
	var prefix_key = prefix + "_" + key if prefix != "" else key
	if skin.has(prefix_key + theme): return skin[prefix_key + theme]
	if skin.has(prefix_key): return skin[prefix_key]
	if skin.has(key + theme): return skin[key + theme]
	if skin.has(key): return skin[key]
	return null

func refresh_all_grass() -> void:
	var was_pattern = false
	if main.pattern_window.m3_floor != null:
		was_pattern = (main.active_floor == main.pattern_window.m3_floor)
	main.set_active_map(false)
	var used_cells = main.layer_floor.get_used_cells()
	for cell in used_cells:
		apply_bitmask_to_single_cell(cell, main.layer_floor, TileSkinData.grass_bitmask_repo, TileSkinData.GRASS_SOURCE_ID)
	main.set_active_map(was_pattern)

func paint_smart_tile(is_just_clicked: bool = false) -> void:
	var mouse_pos = main.get_global_mouse_position()
	var grid_pos = main.layer_floor.local_to_map(mouse_pos)
	if main._get_platform_at(grid_pos) != null:
		return
	var arrival_pos = main.layer_floor.local_to_map(main.sprite_arrival.global_position)
	if grid_pos == arrival_pos and main.current_brush != TileSkinData.Brush.GRASS:
		return
	var has_grass = main.layer_floor.get_cell_source_id(grid_pos) == TileSkinData.GRASS_SOURCE_ID
	var has_wall = main.layer_wall.get_cell_source_id(grid_pos) == TileSkinData.WALL_SOURCE_ID
	var has_ice = main.layer_ice.get_cell_source_id(grid_pos) == TileSkinData.ICE_SOURCE_ID
	var is_empty = not has_wall and not has_ice and not has_grass
	var current_theme = main.cell_themes.get(grid_pos, "")
	var is_trans = current_theme == "_trans"
	var is_bridge = current_theme == "_bridge_v" or current_theme == "_bridge_h"
	var is_fragreen = current_theme == "_fragreen"
	var is_frawood = current_theme == "_frawood"
	var is_hidden = current_theme == "_hidden"
	
	if main.ui_layer.get("is_locked") and main.ui_layer.is_locked:
		match main.current_brush:
			TileSkinData.Brush.GRASS:
				if not is_empty and not (has_grass and not is_trans and not is_bridge and not has_ice and not is_fragreen and not is_frawood and not is_hidden): return
			TileSkinData.Brush.TRANS:
				if not is_empty and not is_trans: return
			TileSkinData.Brush.BRIDGE:
				if not is_empty and not is_bridge: return
			TileSkinData.Brush.WALL:
				if not is_empty and not has_wall: return
			TileSkinData.Brush.ICE:
				if not is_empty and not has_ice: return
			TileSkinData.Brush.FRAGREEN:
				if not is_empty and not is_fragreen: return
			TileSkinData.Brush.FRAWOOD:
				if not is_empty and not is_frawood: return
			TileSkinData.Brush.HIDDEN:
				if not is_empty and not is_hidden: return
				
	match main.current_brush:
		TileSkinData.Brush.HIDDEN:
			if current_theme != "_hidden":
				main._spawn_hidden(grid_pos, "_hidden")
				update_smart_area(grid_pos)
				
		TileSkinData.Brush.FRAGREEN, TileSkinData.Brush.FRAWOOD:
			var target_theme = "_fragreen" if main.current_brush == TileSkinData.Brush.FRAGREEN else "_frawood"
			if current_theme != target_theme:
				main._spawn_fragile(grid_pos, target_theme)
				update_smart_area(grid_pos)
				
		TileSkinData.Brush.GRASS:
			var is_real_grass = has_grass and not is_trans and not is_bridge and not has_ice and not is_fragreen and not is_frawood and not is_hidden
			if is_just_clicked:
				if is_trans or is_bridge or is_fragreen or is_frawood or is_hidden:
					main.is_repainting_theme = false
					main._remove_fragile(grid_pos)
					main._remove_hidden(grid_pos)
					main.cell_themes[grid_pos] = "_light"
					main.layer_floor.set_cell(grid_pos, TileSkinData.GRASS_SOURCE_ID, Vector2i(0,0))
					main.layer_wall.set_cell(grid_pos, -1)
					main.layer_ice.set_cell(grid_pos, -1)
					_update_arrow_color(grid_pos, "_light")
					update_smart_area(grid_pos)
				elif is_real_grass:
					main.is_repainting_theme = true
					var current_grass_theme = main.cell_themes.get(grid_pos, "_light")
					main.current_target_theme = "_dark" if current_grass_theme == "_light" else "_light"
					main.cell_themes[grid_pos] = main.current_target_theme
					_update_arrow_color(grid_pos, main.current_target_theme)
					update_smart_area(grid_pos)
				else:
					main.is_repainting_theme = false
					main._remove_fragile(grid_pos)
					main._remove_hidden(grid_pos)
					main.cell_themes[grid_pos] = "_light"
					main.layer_floor.set_cell(grid_pos, TileSkinData.GRASS_SOURCE_ID, Vector2i(0,0))
					main.layer_wall.set_cell(grid_pos, -1)
					main.layer_ice.set_cell(grid_pos, -1)
					_update_arrow_color(grid_pos, "_light")
					update_smart_area(grid_pos)
			else:
				if main.is_repainting_theme:
					if is_real_grass and main.cell_themes.get(grid_pos, "_light") != main.current_target_theme:
						main.cell_themes[grid_pos] = main.current_target_theme
						_update_arrow_color(grid_pos, main.current_target_theme)
						update_smart_area(grid_pos)
				else:
					if not is_real_grass:
						main._remove_fragile(grid_pos)
						main._remove_hidden(grid_pos)
						main.cell_themes[grid_pos] = "_light"
						main.layer_floor.set_cell(grid_pos, TileSkinData.GRASS_SOURCE_ID, Vector2i(0,0))
						main.layer_wall.set_cell(grid_pos, -1)
						main.layer_ice.set_cell(grid_pos, -1)
						_update_arrow_color(grid_pos, "_light")
						update_smart_area(grid_pos)
						
		TileSkinData.Brush.ICE:
			if main.layer_ice.get_cell_source_id(grid_pos) != TileSkinData.ICE_SOURCE_ID:
				main._remove_fragile(grid_pos)
				main._remove_hidden(grid_pos)
				apply_custom_cell(main.layer_ice, grid_pos, TileSkinData.ICE_SOURCE_ID, get_tile_variation(grid_pos, get_skin_element("", "ice"), "ice"))
				main.layer_floor.set_cell(grid_pos, TileSkinData.GRASS_SOURCE_ID, Vector2i(0,0))
				if not main.cell_themes.has(grid_pos) or is_fragreen or is_frawood or is_trans or is_bridge or is_hidden:
					main.cell_themes[grid_pos] = "_light"
				main.layer_wall.set_cell(grid_pos, -1)
				main.layer_deco.set_cell(grid_pos, -1)
				update_smart_area(grid_pos)
				
		TileSkinData.Brush.WALL:
			if _is_protected_entity_at(grid_pos):
				return
			if main.layer_wall.get_cell_source_id(grid_pos) != TileSkinData.WALL_SOURCE_ID:
				main._remove_fragile(grid_pos)
				main._remove_hidden(grid_pos)
				main.layer_wall.set_cell(grid_pos, TileSkinData.WALL_SOURCE_ID, Vector2i(0, 0))
				main.layer_floor.set_cell(grid_pos, -1)
				main.layer_ice.set_cell(grid_pos, -1)
				main.layer_deco.set_cell(grid_pos, -1)
				main.cell_themes.erase(grid_pos)
				update_smart_area(grid_pos)
				
		TileSkinData.Brush.TRANS:
			if current_theme != "_trans":
				main._remove_fragile(grid_pos)
				main._remove_hidden(grid_pos)
				main.cell_themes[grid_pos] = "_trans"
				main.layer_floor.set_cell(grid_pos, TileSkinData.GRASS_SOURCE_ID, Vector2i(0,0))
				main.layer_wall.set_cell(grid_pos, -1)
				main.layer_ice.set_cell(grid_pos, -1)
				main.layer_deco.set_cell(grid_pos, -1)
				update_smart_area(grid_pos)
				
		TileSkinData.Brush.BRIDGE:
			if is_just_clicked:
				if is_bridge:
					main.is_repainting_theme = true
					main.current_target_theme = "_bridge_h" if current_theme == "_bridge_v" else "_bridge_v"
					main.cell_themes[grid_pos] = main.current_target_theme
					update_smart_area(grid_pos)
				else:
					main.is_repainting_theme = false
					main._remove_fragile(grid_pos)
					main._remove_hidden(grid_pos)
					main.cell_themes[grid_pos] = "_bridge_h"
					main.layer_floor.set_cell(grid_pos, TileSkinData.GRASS_SOURCE_ID, Vector2i(0,0))
					main.layer_wall.set_cell(grid_pos, -1)
					main.layer_ice.set_cell(grid_pos, -1)
					main.layer_deco.set_cell(grid_pos, -1)
					update_smart_area(grid_pos)
			else:
				if main.is_repainting_theme:
					if is_bridge and current_theme != main.current_target_theme:
						main.cell_themes[grid_pos] = main.current_target_theme
						update_smart_area(grid_pos)
				else:
					if not is_bridge:
						main._remove_fragile(grid_pos)
						main._remove_hidden(grid_pos)
						main.cell_themes[grid_pos] = "_bridge_h"
						main.layer_floor.set_cell(grid_pos, TileSkinData.GRASS_SOURCE_ID, Vector2i(0,0))
						main.layer_wall.set_cell(grid_pos, -1)
						main.layer_ice.set_cell(grid_pos, -1)
						main.layer_deco.set_cell(grid_pos, -1)
						update_smart_area(grid_pos)
		TileSkinData.Brush.DECO:
			if is_just_clicked:
				var current_map_coords = main.layer_deco.get_cell_atlas_coords(grid_pos)
				if current_map_coords != Vector2i(-1, -1):
					var expected_data = _get_current_deco_atlas_data(grid_pos)
					if expected_data.x != -1 and current_map_coords == Vector2i(expected_data.x, expected_data.y):
						main._cycle_deco_category(1)
			if has_grass and not is_trans and not is_bridge and not is_fragreen and not is_frawood and not is_hidden:
				_apply_deco(grid_pos)

func _apply_brush_to_layer(grid_pos: Vector2i, target_layer: TileMapLayer, source_id: int) -> void:
	if source_id == TileSkinData.GRASS_SOURCE_ID:
		target_layer.set_cell(grid_pos, source_id, Vector2i(0,0))
		main.layer_ice.set_cell(grid_pos, -1)
	else:
		apply_custom_cell(target_layer, grid_pos, source_id, get_tile_variation(grid_pos, get_skin_element("", "ice"), "ice"))
		main.layer_floor.set_cell(grid_pos, TileSkinData.GRASS_SOURCE_ID, Vector2i(0,0))
	main.layer_wall.set_cell(grid_pos, -1)

func erase_all_layers(specific_pos = null, is_just_clicked: bool = false) -> void:
	var grid_pos = specific_pos if specific_pos != null else main.layer_floor.local_to_map(main.get_global_mouse_position())
	var has_deco = false
	if main.layer_deco != null:
		has_deco = (main.layer_deco.get_cell_source_id(grid_pos) != -1)
	if is_just_clicked:
		if main.current_brush == TileSkinData.Brush.DECO and has_deco:
			is_erasing_deco_only = true
		else:
			is_erasing_deco_only = false
	var has_wall = main.layer_wall.get_cell_source_id(grid_pos) == TileSkinData.WALL_SOURCE_ID
	var has_ice = main.layer_ice.get_cell_source_id(grid_pos) == TileSkinData.ICE_SOURCE_ID
	var has_grass = main.layer_floor.get_cell_source_id(grid_pos) == TileSkinData.GRASS_SOURCE_ID
	var current_theme = main.cell_themes.get(grid_pos, "")
	var is_trans = current_theme == "_trans"
	var is_bridge = current_theme == "_bridge_v" or current_theme == "_bridge_h"
	var is_fragreen = current_theme == "_fragreen"
	var is_frawood = current_theme == "_frawood"
	var is_hidden = current_theme == "_hidden"
	if main.ui_layer.get("is_locked") and main.ui_layer.is_locked:
		var matches_selection = false
		match main.current_brush:
			TileSkinData.Brush.GRASS:
				matches_selection = (has_grass and not is_trans and not is_bridge and not has_ice and not is_fragreen and not is_frawood and not is_hidden)
			TileSkinData.Brush.TRANS:
				matches_selection = is_trans
			TileSkinData.Brush.BRIDGE:
				matches_selection = is_bridge
			TileSkinData.Brush.WALL:
				matches_selection = has_wall
			TileSkinData.Brush.ICE:
				matches_selection = has_ice
			TileSkinData.Brush.FRAGREEN:
				matches_selection = is_fragreen
			TileSkinData.Brush.FRAWOOD:
				matches_selection = is_frawood
			TileSkinData.Brush.HIDDEN:
				matches_selection = is_hidden
			TileSkinData.Brush.DECO:
				matches_selection = has_deco
		if not matches_selection:
			return
	if is_erasing_deco_only or main.current_brush == TileSkinData.Brush.DECO:
		if has_deco:
			main.layer_deco.set_cell(grid_pos, -1)
		return
	if _is_protected_entity_at(grid_pos):
		return
	if main._get_platform_at(grid_pos) != null:
		return
	var arrival_pos = main.layer_floor.local_to_map(main.sprite_arrival.global_position)
	if grid_pos == arrival_pos:
		return
	main.cell_themes.erase(grid_pos)
	main.layer_floor.set_cell(grid_pos, -1)
	main.layer_wall.set_cell(grid_pos, -1)
	main.layer_ice.set_cell(grid_pos, -1)
	main.layer_deco.set_cell(grid_pos, -1)
	main._remove_fragile(grid_pos)
	main._remove_hidden(grid_pos)
	update_smart_area(grid_pos)

func update_smart_area(cell_pos: Vector2i, is_pattern: bool = false) -> void:
	main.set_active_map(is_pattern)
	var layers_to_clear = [main.active_persp_up, main.active_persp_up_wall, main.active_persp_up_ice, main.active_persp_right, main.active_persp_right_wall, main.active_persp_Eright_wall, main.active_persp_right_ice, main.active_persp_Wright, main.active_persp_Wdown, main.active_persp_Wleft]
	for x in range(-2, 3):
		for y in range(-2, 3):
			var target_cell = cell_pos + Vector2i(x, y)
			for l in layers_to_clear:
				if l != null: l.set_cell(target_cell, -1)
	for x in range(-3, 4):
		for y in range(-3, 4):
			var target_cell = cell_pos + Vector2i(x, y)
			if get_source_id(main.active_wall, target_cell) == TileSkinData.WALL_SOURCE_ID:
				apply_bitmask_to_single_cell(target_cell, main.active_wall, TileSkinData.wall_bitmask_repo, TileSkinData.WALL_SOURCE_ID)
			if get_source_id(main.active_floor, target_cell) == TileSkinData.GRASS_SOURCE_ID:
				apply_bitmask_to_single_cell(target_cell, main.active_floor, TileSkinData.grass_bitmask_repo, TileSkinData.GRASS_SOURCE_ID)
			if get_source_id(main.active_ice, target_cell) == TileSkinData.ICE_SOURCE_ID:
				apply_bitmask_to_single_cell(target_cell, main.active_ice, TileSkinData.grass_bitmask_repo, TileSkinData.ICE_SOURCE_ID)
	if is_pattern: main.set_active_map(false)

func is_grass_or_ice(pos: Vector2i) -> bool:
	if main.active_floor == main.layer_floor:
		var theme = main.cell_themes.get(pos)
		if theme == "_trans" or theme == "_bridge_v" or theme == "_bridge_h" or theme == "_frawood" or theme == "_fragreen" or theme == "_hidden":
			return false
	return get_source_id(main.active_floor, pos) == TileSkinData.GRASS_SOURCE_ID

func get_grass_theme(cell_pos: Vector2i) -> String:
	if main.active_floor == main.layer_floor:
		var theme = main.cell_themes.get(cell_pos)
		if theme == "_trans" or theme == "_bridge_v" or theme == "_bridge_h" or theme == "_fragreen" or theme == "_frawood" or theme == "_hidden":
			return theme
	if main.pattern_window.m3_floor != null and main.active_floor == main.pattern_window.m3_floor:
		return main.pattern_window.pattern_cell_themes.get(cell_pos, "_light")
	match main.grass_mode:
		1: return main.cell_themes.get(cell_pos, "_light")
		2: return "_light" if posmod(cell_pos.x + cell_pos.y, 2) == 0 else "_dark"
		3:
			if main.pattern_window.custom_pattern.is_empty():
				return "_light"
			var px = posmod(cell_pos.x, main.pattern_window.pattern_size.x)
			var py = posmod(cell_pos.y, main.pattern_window.pattern_size.y)
			return main.pattern_window.custom_pattern.get(Vector2i(px, py), "_light")
	return "_light"

func generate_grass_under(pos: Vector2i) -> void:
	main._remove_fragile(pos)
	main._remove_hidden(pos)
	main.layer_ice.set_cell(pos, -1)
	main.layer_wall.set_cell(pos, -1)
	main.cell_themes[pos] = "_light"
	_update_arrow_color(pos, "_light")
	main.layer_floor.set_cell(pos, TileSkinData.GRASS_SOURCE_ID, Vector2i(0,0))
	update_smart_area(pos)

func apply_bitmask_to_single_cell(cell_pos: Vector2i, layer: TileMapLayer, repo: Dictionary, source_id: int) -> void:
	if layer == null: return
	var theme = get_grass_theme(cell_pos)
	
	if source_id == TileSkinData.GRASS_SOURCE_ID:
		if theme == "_fragreen" or theme == "_frawood" or theme == "_hidden":
			apply_custom_cell(layer, cell_pos, source_id, Vector2i(14, 0)) 
			return
		elif theme == "_trans":
			var trans_key = "visible_transparent" if Input.is_key_pressed(KEY_SPACE) else "transparent"
			var trans_atlas = get_tile_variation(cell_pos, get_skin_element("", trans_key), trans_key)
			apply_custom_cell(layer, cell_pos, source_id, trans_atlas)
			return
		elif theme == "_bridge_v" or theme == "_bridge_h":
			var bridge_key = theme.substr(1) 
			var bridge_atlas = get_tile_variation(cell_pos, get_skin_element("", bridge_key), bridge_key)
			apply_custom_cell(layer, cell_pos, source_id, bridge_atlas)
			return
			
	var score : int = 0
	if source_id == TileSkinData.WALL_SOURCE_ID:
		if is_tile_connected(layer, cell_pos + Vector2i.UP, source_id):    score += 1
		if is_tile_connected(layer, cell_pos + Vector2i.RIGHT, source_id): score += 2
		if is_tile_connected(layer, cell_pos + Vector2i.DOWN, source_id):  score += 4
		if is_tile_connected(layer, cell_pos + Vector2i.LEFT, source_id) or is_grass_or_ice(cell_pos + Vector2i.LEFT):  score += 8
	else:
		if is_tile_connected(layer, cell_pos + Vector2i.UP, source_id):    score += 1
		if is_tile_connected(layer, cell_pos + Vector2i.RIGHT, source_id): score += 2
		if is_tile_connected(layer, cell_pos + Vector2i.DOWN, source_id):  score += 4
		if is_tile_connected(layer, cell_pos + Vector2i.LEFT, source_id):  score += 8
		
	var main_theme_key = "dark" if theme == "_dark" else "light"
	if source_id == TileSkinData.GRASS_SOURCE_ID:
		var main_atlas = get_tile_variation(cell_pos, get_skin_element("floor", main_theme_key), main_theme_key)
		apply_custom_cell(layer, cell_pos, source_id, main_atlas)
	elif source_id == TileSkinData.ICE_SOURCE_ID:
		apply_custom_cell(layer, cell_pos, source_id, get_tile_variation(cell_pos, get_skin_element("", "ice"), "ice"))
		var border_source_id = TileSkinData.GRASS_SOURCE_ID
		var no_up = get_source_id(main.active_ice, cell_pos + Vector2i.UP) != TileSkinData.ICE_SOURCE_ID and get_source_id(main.active_wall, cell_pos + Vector2i.UP) != TileSkinData.WALL_SOURCE_ID
		var no_right = get_source_id(main.active_ice, cell_pos + Vector2i.RIGHT) != TileSkinData.ICE_SOURCE_ID and get_source_id(main.active_wall, cell_pos + Vector2i.RIGHT) != TileSkinData.WALL_SOURCE_ID
		var no_up_right = get_source_id(main.active_ice, cell_pos + Vector2i(1, -1)) != TileSkinData.ICE_SOURCE_ID and get_source_id(main.active_wall, cell_pos + Vector2i(1, -1)) != TileSkinData.WALL_SOURCE_ID
		if no_up: apply_custom_cell(main.active_persp_up_ice, cell_pos + Vector2i.UP, border_source_id, get_tile_variation(cell_pos, get_skin_element("up_ice", "normal_ice"), "up_ice"))
		if no_right: apply_custom_cell(main.active_persp_right_ice, cell_pos + Vector2i.RIGHT, border_source_id, get_tile_variation(cell_pos, get_skin_element("right_ice", "ice"), "right_ice"))
		if no_up and no_right and no_up_right: apply_custom_cell(main.active_persp_up_ice, cell_pos + Vector2i(1, -1), border_source_id, get_tile_variation(cell_pos, get_skin_element("up_ice", "E_ice"), "up_ice_E"))
		
	if repo.has(score):
		var variations = repo[score]
		var pseudo_rand = posmod(hash(cell_pos), variations.size())
		var tile_data = variations[pseudo_rand].duplicate(true)
		var border_source_id = source_id
		if source_id == TileSkinData.ICE_SOURCE_ID:
			border_source_id = TileSkinData.GRASS_SOURCE_ID
		if source_id == TileSkinData.WALL_SOURCE_ID and tile_data.has("main") and tile_data["main"] != null:
			var data = tile_data["main"]
			if typeof(data) == TYPE_DICTIONARY:
				for offset in data:
					var final_atlas = get_tile_variation(cell_pos, get_skin_element("wall", str(data[offset])), "main_" + str(offset))
					apply_custom_cell(layer, cell_pos + offset, source_id, final_atlas)
			else:
				var final_atlas = get_tile_variation(cell_pos, get_skin_element("wall", str(data)), "main")
				apply_custom_cell(layer, cell_pos, source_id, final_atlas)
				
		var process_water_right = func(w_data):
			var has_solid_right = get_source_id(main.active_wall, cell_pos + Vector2i.RIGHT) == TileSkinData.WALL_SOURCE_ID or is_grass_or_ice(cell_pos + Vector2i.RIGHT)
			if has_solid_right: return 
			var blocked_eright_wall = (
				get_source_id(main.active_wall, cell_pos + Vector2i.RIGHT) == TileSkinData.WALL_SOURCE_ID or
				is_grass_or_ice(cell_pos + Vector2i.RIGHT) or
				get_source_id(main.active_wall, cell_pos + Vector2i.DOWN) == TileSkinData.WALL_SOURCE_ID or
				is_grass_or_ice(cell_pos + Vector2i.DOWN) or
				get_source_id(main.active_wall, cell_pos + Vector2i(1, 1)) == TileSkinData.WALL_SOURCE_ID or
				is_grass_or_ice(cell_pos + Vector2i(1, 1)))
			if typeof(w_data) == TYPE_DICTIONARY:
				for offset in w_data:
					var tex = str(w_data[offset])
					if tex == "Eright_wall" and blocked_eright_wall: continue
					var target_pos = cell_pos + offset
					if tex == "normal":
						var coords_above = get_atlas_coords(main.active_persp_Wright, target_pos + Vector2i.UP)
						tex = "full" if (coords_above.y == 2 or coords_above.y == 3) else "mini"
					var final_atlas = get_skin_element("water_right", tex, theme)
					apply_custom_cell(main.active_persp_Wright, target_pos, border_source_id, get_tile_variation(cell_pos, final_atlas, "water_right_" + str(offset)))
			else:
				var tex = str(w_data)
				if not (tex == "Eright_wall" and blocked_eright_wall):
					var target_pos = cell_pos + Vector2i.RIGHT
					if tex == "normal":
						var coords_above = get_atlas_coords(main.active_persp_Wright, target_pos + Vector2i.UP)
						tex = "full" if (coords_above.y == 2 or coords_above.y == 3) else "mini"
					var final_atlas = get_skin_element("water_right", tex, theme)
					apply_custom_cell(main.active_persp_Wright, target_pos, border_source_id, get_tile_variation(cell_pos, final_atlas, "water_right"))

		if tile_data.has("persp_down_water") and tile_data["persp_down_water"] != null:
			var data = tile_data["persp_down_water"]
			if typeof(data) == TYPE_DICTIONARY:
				for offset in data:
					var final_atlas = get_skin_element("water_down", str(data[offset]), theme)
					apply_custom_cell(main.active_persp_Wdown, cell_pos + offset, border_source_id, get_tile_variation(cell_pos, final_atlas, "persp_down_water_" + str(offset)))
			else:
				var final_atlas = get_skin_element("water_down", str(data), theme)
				apply_custom_cell(main.active_persp_Wdown, cell_pos + Vector2i.DOWN, border_source_id, get_tile_variation(cell_pos, final_atlas, "persp_down_water"))

		if source_id != TileSkinData.ICE_SOURCE_ID and tile_data.has("persp_up") and tile_data["persp_up"] != null:
			var data = tile_data["persp_up"]
			var no_up = not is_tile_connected(layer, cell_pos + Vector2i.UP, source_id)
			var no_right = not is_tile_connected(layer, cell_pos + Vector2i.RIGHT, source_id)
			var no_up_right = not is_tile_connected(layer, cell_pos + Vector2i(1, -1), source_id)
			if no_up and no_right and no_up_right:
				if typeof(data) != TYPE_DICTIONARY:
					if data == "normal": data = { Vector2i(0, -1): "normal", Vector2i(1, -1): "E" }
			if typeof(data) == TYPE_DICTIONARY:
				for offset in data:
					var final_atlas = get_skin_element("up", str(data[offset]), theme)
					apply_custom_cell(main.active_persp_up, cell_pos + offset, border_source_id, get_tile_variation(cell_pos, final_atlas, "persp_up_" + str(offset)))
			else:
				var final_atlas = get_skin_element("up", str(data), theme)
				apply_custom_cell(main.active_persp_up, cell_pos + Vector2i.UP, border_source_id, get_tile_variation(cell_pos, final_atlas, "persp_up"))

		if tile_data.has("persp_left_water") and tile_data["persp_left_water"] != null:
			var data = tile_data["persp_left_water"]
			var forbid_eleft = (source_id == TileSkinData.WALL_SOURCE_ID and is_grass_or_ice(cell_pos + Vector2i.DOWN))
			if is_tile_connected(layer, cell_pos + Vector2i(-1, -1), source_id):
				if typeof(data) == TYPE_DICTIONARY:
					var modified_data = data.duplicate()
					for offset in modified_data:
						if str(modified_data[offset]) == "full": modified_data[offset] = "mini"
					data = modified_data
				else:
					if str(data) == "full": data = "mini"
			var has_down_left = is_tile_connected(layer, cell_pos + Vector2i(-1, 1), source_id)
			if (has_down_left or forbid_eleft) and typeof(data) == TYPE_DICTIONARY:
				var modified_data = data.duplicate()
				var keys_to_erase = []
				for offset in modified_data:
					if str(modified_data[offset]) == "Eleft": keys_to_erase.append(offset)
				for k in keys_to_erase: modified_data.erase(k)
				data = modified_data
			if typeof(data) == TYPE_DICTIONARY:
				for offset in data:
					var tex = str(data[offset])
					var target_pos = cell_pos + offset
					if tex == "mini" or tex == "full":
						var coords_above = get_atlas_coords(main.active_persp_Wleft, target_pos + Vector2i.UP)
						tex = "full" if (coords_above.y == 2 or coords_above.y == 3) else "mini"
					var final_atlas = get_skin_element("water_left", tex, theme)
					apply_custom_cell(main.active_persp_Wleft, target_pos, border_source_id, get_tile_variation(cell_pos, final_atlas, "persp_left_water_" + str(offset)))
			else:
				var tex = str(data)
				var target_pos = cell_pos + Vector2i.LEFT
				if tex == "mini" or tex == "full":
					var coords_above = get_atlas_coords(main.active_persp_Wleft, target_pos + Vector2i.UP)
					tex = "full" if (coords_above.y == 2 or coords_above.y == 3) else "mini"
				var final_atlas = get_skin_element("water_left", tex, theme)
				apply_custom_cell(main.active_persp_Wleft, target_pos, border_source_id, get_tile_variation(cell_pos, final_atlas, "persp_left_water"))

		if tile_data.has("persp_right") and tile_data["persp_right"] != null:
			var data = tile_data["persp_right"]
			process_water_right.call(data)
			if source_id != TileSkinData.ICE_SOURCE_ID:
				if typeof(data) == TYPE_DICTIONARY:
					for offset in data:
						var final_atlas = get_skin_element("right", str(data[offset]), theme)
						apply_custom_cell(main.active_persp_right, cell_pos + offset, border_source_id, get_tile_variation(cell_pos, final_atlas, "persp_right_" + str(offset)))
				else:
					var final_atlas = get_skin_element("right", str(data), theme)
					apply_custom_cell(main.active_persp_right, cell_pos + Vector2i.RIGHT, border_source_id, get_tile_variation(cell_pos, final_atlas, "persp_right"))

		if tile_data.has("persp_right_wall") and tile_data["persp_right_wall"] != null:
			var data = tile_data["persp_right_wall"]
			process_water_right.call(data)
			var forbid_eright_wall = (source_id == TileSkinData.WALL_SOURCE_ID and is_grass_or_ice(cell_pos + Vector2i.DOWN))
			var has_down_right = is_tile_connected(layer, cell_pos + Vector2i(1, 1), source_id)
			var has_grass_down_right = (source_id == TileSkinData.WALL_SOURCE_ID and is_grass_or_ice(cell_pos + Vector2i(1, 1)))
			if (has_down_right or forbid_eright_wall or has_grass_down_right) and typeof(data) == TYPE_DICTIONARY:
				var modified_data = data.duplicate()
				var keys_to_erase = []
				for offset in modified_data:
					if str(modified_data[offset]) == "Eright_wall": keys_to_erase.append(offset)
				for k in keys_to_erase: modified_data.erase(k)
				data = modified_data
			if typeof(data) == TYPE_DICTIONARY:
				for offset in data:
					var tex = str(data[offset])
					var final_atlas = get_skin_element("right_wall", tex, theme)
					var target_pos = cell_pos + offset
					if tex == "Eright_wall":
						apply_custom_cell(main.active_persp_Eright_wall, target_pos, border_source_id, get_tile_variation(cell_pos, final_atlas, "persp_Eright_wall_" + str(offset)))
					else:
						apply_custom_cell(main.active_persp_right_wall, target_pos, border_source_id, get_tile_variation(cell_pos, final_atlas, "persp_right_wall_" + str(offset)))
			else:
				var tex = str(data)
				var final_atlas = get_skin_element("right_wall", tex, theme)
				var target_pos = cell_pos + Vector2i.RIGHT
				if tex == "Eright_wall":
					apply_custom_cell(main.active_persp_Eright_wall, target_pos, border_source_id, get_tile_variation(cell_pos, final_atlas, "persp_Eright_wall"))
				else:
					apply_custom_cell(main.active_persp_right_wall, target_pos, border_source_id, get_tile_variation(cell_pos, final_atlas, "persp_right_wall"))

		if tile_data.has("persp_up_wall") and tile_data["persp_up_wall"] != null:
			var data = tile_data["persp_up_wall"]
			if typeof(data) == TYPE_DICTIONARY:
				for offset in data:
					var final_atlas = get_skin_element("up_wall", str(data[offset]), theme)
					apply_custom_cell(main.active_persp_up_wall, cell_pos + offset, border_source_id, get_tile_variation(cell_pos, final_atlas, "persp_up_wall_" + str(offset)))
			else:
				var final_atlas = get_skin_element("up_wall", str(data), theme)
				apply_custom_cell(main.active_persp_up_wall, cell_pos + Vector2i.UP, border_source_id, get_tile_variation(cell_pos, final_atlas, "persp_up_wall"))

func get_tile_variation(cell_pos: Vector2i, data_source: Variant, layer_type: String) -> Variant:
	if typeof(data_source) != TYPE_ARRAY: return data_source
	var base_hash = hash(cell_pos)
	var seed_offset = hash(layer_type)
	var rand_idx = posmod(base_hash + seed_offset, data_source.size())
	return data_source[rand_idx]

func apply_custom_cell(layer: TileMapLayer, target_pos: Vector2i, default_source_id: int, atlas_data: Variant) -> void:
	if layer == null: return
	if atlas_data == null or typeof(atlas_data) == TYPE_STRING: return
	var final_source_id = default_source_id
	var final_coords = atlas_data
	if typeof(atlas_data) == TYPE_VECTOR3I:
		final_coords = Vector2i(atlas_data.x, atlas_data.y)
		final_source_id = atlas_data.z
	layer.set_cell(target_pos, final_source_id, final_coords)

func is_tile_connected(layer: TileMapLayer, pos: Vector2i, base_source_id: int) -> bool:
	if base_source_id == TileSkinData.GRASS_SOURCE_ID or base_source_id == TileSkinData.ICE_SOURCE_ID:
		return is_grass_or_ice(pos) or get_source_id(main.active_wall, pos) == TileSkinData.WALL_SOURCE_ID
	return get_source_id(layer, pos) == base_source_id

func rafraichir_autotiling_global() -> void:
	var toutes_les_cases: Dictionary = {}
	for pos in main.layer_wall.get_used_cells():
		toutes_les_cases[pos] = true
	for pos in main.layer_floor.get_used_cells():
		toutes_les_cases[pos] = true
	for pos in main.layer_ice.get_used_cells():
		toutes_les_cases[pos] = true
	var liste_triee: Array[Vector2i] = []
	for pos in toutes_les_cases.keys():
		liste_triee.append(pos)
	liste_triee.sort_custom(func(a: Vector2i, b: Vector2i) -> bool:
		if a.y == b.y:
			return a.x < b.x
		return a.y < b.y)
	for pos in liste_triee:
		if get_source_id(main.layer_wall, pos) == TileSkinData.WALL_SOURCE_ID:
			apply_bitmask_to_single_cell(pos, main.layer_wall, TileSkinData.wall_bitmask_repo, TileSkinData.WALL_SOURCE_ID)
		if get_source_id(main.layer_floor, pos) == TileSkinData.GRASS_SOURCE_ID:
			apply_bitmask_to_single_cell(pos, main.layer_floor, TileSkinData.grass_bitmask_repo, TileSkinData.GRASS_SOURCE_ID)
		if get_source_id(main.layer_ice, pos) == TileSkinData.ICE_SOURCE_ID:
			apply_bitmask_to_single_cell(pos, main.layer_ice, TileSkinData.grass_bitmask_repo, TileSkinData.ICE_SOURCE_ID)

func _is_protected_entity_at(grid_pos: Vector2i) -> bool:
	var player_pos = main.layer_floor.local_to_map(main.sprite_player.global_position)
	if grid_pos == player_pos:
		return true
	for door in get_tree().get_nodes_in_group("Doors"):
		if door.is_queued_for_deletion():
			continue
		if main.layer_floor.local_to_map(door.global_position) == grid_pos:
			return true
		var keys_container = door.get_node_or_null("Keys")
		if keys_container:
			for key in keys_container.get_children():
				if not key.is_queued_for_deletion() and main.layer_floor.local_to_map(key.global_position) == grid_pos:
					return true
	for portal in get_tree().get_nodes_in_group("Portals"):
		if portal.is_queued_for_deletion():
			continue
		if main.layer_floor.local_to_map(portal.global_position) == grid_pos:
			return true
	return false

func _get_current_deco_atlas_data(grid_pos: Vector2i) -> Vector3i:
	var cat = main.current_deco_category
	var idx = main.current_deco_index
	var theme = get_grass_theme(grid_pos) 
	var deco_dict = get_skin_element("", "deco")
	if typeof(deco_dict) == TYPE_DICTIONARY:
		if cat == "arrow":
			var sub_cat = "arrow_dark" if theme == "_dark" else "arrow_light"
			if deco_dict.has("arrow") and deco_dict["arrow"].has(sub_cat):
				if deco_dict["arrow"][sub_cat].size() > idx:
					return deco_dict["arrow"][sub_cat][idx]
		else:
			if deco_dict.has(cat):
				if deco_dict[cat].size() > idx:
					return deco_dict[cat][idx]
	return Vector3i(-1, -1, -1)

func _apply_deco(grid_pos: Vector2i) -> void:
	if main.layer_deco == null: return
	var atlas_coords = _get_current_deco_atlas_data(grid_pos)
	if atlas_coords.x != -1:
		main.layer_deco.set_cell(grid_pos, atlas_coords.z, Vector2i(atlas_coords.x, atlas_coords.y))

func _update_arrow_color(grid_pos: Vector2i, new_theme: String) -> void:
	if main.layer_deco == null: return
	var current_coords = main.layer_deco.get_cell_atlas_coords(grid_pos)
	if current_coords == Vector2i(-1, -1): return # Pas de déco sur cette case
	var source_id = main.layer_deco.get_cell_source_id(grid_pos)
	if current_coords.y == 3 and new_theme == "_light":
		main.layer_deco.set_cell(grid_pos, source_id, Vector2i(current_coords.x, 4))
	elif current_coords.y == 4 and new_theme == "_dark":
		main.layer_deco.set_cell(grid_pos, source_id, Vector2i(current_coords.x, 3))

func get_deco_atlas_coords(cat: String, idx: int) -> Vector2i:
	var deco_dict = get_skin_element("", "deco")
	if typeof(deco_dict) == TYPE_DICTIONARY:
		if cat == "arrow":
			if deco_dict.has("arrow") and deco_dict["arrow"].has("arrow_dark"):
				var arr = deco_dict["arrow"]["arrow_dark"]
				if arr.size() > idx:
					return Vector2i(arr[idx].x, arr[idx].y)
		else:
			if deco_dict.has(cat):
				var arr = deco_dict[cat]
				if arr.size() > idx:
					return Vector2i(arr[idx].x, arr[idx].y)
	return Vector2i(-1, -1)
