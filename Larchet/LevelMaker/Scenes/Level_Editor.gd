extends Node2D

@onready var map_node: Node2D = $MAP
@onready var layer_floor: TileMapLayer = %tileMapLayer_floor
@onready var layer_wall: TileMapLayer = %tileMapLayer_wall
@onready var layer_ice: TileMapLayer = %tileMapLayer_ice
@onready var layer_persp_right: TileMapLayer = %TileMapLayer_perspective_right
@onready var layer_persp_right_wall: TileMapLayer = %TileMapLayer_perspective_right_wall
@onready var layer_persp_Eright_wall: TileMapLayer = %TileMapLayer_perspective_Eright_wall
@onready var layer_persp_right_ice: TileMapLayer = %TileMapLayer_perspective_right_ice
@onready var layer_persp_up: TileMapLayer = %TileMapLayer_perspective_up
@onready var layer_persp_up_wall: TileMapLayer = %TileMapLayer_perspective_up_wall
@onready var layer_persp_up_ice: TileMapLayer = %TileMapLayer_perspective_up_ice
@onready var layer_persp_Wright: TileMapLayer = %TileMapLayer_perspective_water_right
@onready var layer_persp_Wdown: TileMapLayer = %TileMapLayer_perspective_water_down
@onready var layer_persp_Wleft: TileMapLayer = %TileMapLayer_perspective_water_left

@onready var camera: Camera2D = $Camera2D
@onready var ui_layer = $UI_Layer
@onready var pattern_window: Window = %PatternWindow

const PLAYER_SCENE = preload("res://Player/Player.tscn")
var player: Node2D = null

var active_floor: TileMapLayer
var active_wall: TileMapLayer
var active_ice: TileMapLayer
var active_persp_right: TileMapLayer
var active_persp_right_wall: TileMapLayer
var active_persp_Eright_wall: TileMapLayer
var active_persp_right_ice: TileMapLayer
var active_persp_up: TileMapLayer
var active_persp_up_wall: TileMapLayer
var active_persp_up_ice: TileMapLayer
var active_persp_Wright: TileMapLayer
var active_persp_Wdown: TileMapLayer
var active_persp_Wleft: TileMapLayer

var is_repainting_theme: bool = false
var current_target_theme: String = "_light"
var cell_themes: Dictionary = {}

var grass_mode: int = 1
var current_brush: TileSkinData.Brush = TileSkinData.Brush.GRASS
var current_skin_name: String = "Normal"

func get_source_id(layer: TileMapLayer, cell_pos: Vector2i) -> int:
	if layer == null: return -1
	return layer.get_cell_source_id(cell_pos)

func get_atlas_coords(layer: TileMapLayer, cell_pos: Vector2i) -> Vector2i:
	if layer == null: return Vector2i(-1, -1)
	return layer.get_cell_atlas_coords(cell_pos)

func get_skin_element(prefix: String, key: String, theme: String = "") -> Variant:
	if not TileSkinData.SKINS.has(current_skin_name): return null
	var skin = TileSkinData.SKINS[current_skin_name]
	var prefix_key = prefix + "_" + key if prefix != "" else key
	if skin.has(prefix_key + theme): return skin[prefix_key + theme]
	if skin.has(prefix_key): return skin[prefix_key]
	if skin.has(key + theme): return skin[key + theme]
	if skin.has(key): return skin[key]
	return null

func _ready() -> void:
	pattern_window.main_node = self
	pattern_window.hide()
	if ui_layer.has_signal("brush_selected"):
		ui_layer.brush_selected.connect(func(brush): current_brush = brush)
	if ui_layer.has_signal("grass_mode_toggled"):
		ui_layer.grass_mode_toggled.connect(func(mode):
			grass_mode = mode
			if grass_mode != 3: pattern_window.hide()
			refresh_all_grass())
	if ui_layer.has_signal("mode3_toggled"):
		ui_layer.mode3_toggled.connect(func():
			pattern_window.visible = not pattern_window.visible
			if pattern_window.visible:
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE))

func _process(_delta: float) -> void:
	var center_pixel_pos = camera.global_position
	var center_grid_pos = layer_floor.local_to_map(center_pixel_pos)
	if ui_layer.has_method("update_coords"):
		ui_layer.update_coords(center_grid_pos.x, center_grid_pos.y)

func set_active_map(is_pattern: bool) -> void:
	if is_pattern:
		active_floor = pattern_window.m3_floor
		active_wall = null 
		active_ice = null  
		active_persp_right = pattern_window.m3_persp_right
		active_persp_right_wall = null
		active_persp_Eright_wall = null
		active_persp_right_ice = null
		active_persp_up = pattern_window.m3_persp_up
		active_persp_up_wall = null
		active_persp_up_ice = null
		active_persp_Wright = pattern_window.m3_water_right
		active_persp_Wdown = pattern_window.m3_water_down
		active_persp_Wleft = pattern_window.m3_water_left
	else:
		active_floor = layer_floor
		active_wall = layer_wall
		active_ice = layer_ice
		active_persp_right = layer_persp_right
		active_persp_right_wall = layer_persp_right_wall
		active_persp_Eright_wall = layer_persp_Eright_wall
		active_persp_right_ice = layer_persp_right_ice
		active_persp_up = layer_persp_up
		active_persp_up_wall = layer_persp_up_wall
		active_persp_up_ice = layer_persp_up_ice
		active_persp_Wright = layer_persp_Wright
		active_persp_Wdown = layer_persp_Wdown
		active_persp_Wleft = layer_persp_Wleft

func refresh_all_grass() -> void:
	var was_pattern = false
	if pattern_window.m3_floor != null:
		was_pattern = (active_floor == pattern_window.m3_floor)
	set_active_map(false)
	var used_cells = layer_floor.get_used_cells()
	for cell in used_cells:
		apply_bitmask_to_single_cell(cell, layer_floor, TileSkinData.grass_bitmask_repo, TileSkinData.GRASS_SOURCE_ID)
	set_active_map(was_pattern)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion or event is InputEventMouseButton:
		var is_left_clicking = Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
		var is_right_clicking = Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT)
		var is_just_clicked = false
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			is_just_clicked = true
		if is_left_clicking and not camera.is_panning:
			paint_smart_tile(is_just_clicked)
		elif is_right_clicking and not camera.is_panning:
			erase_all_layers()
	if event is InputEventKey:
		if event.keycode == KEY_SPACE and not event.echo:
			refresh_all_grass()

func paint_smart_tile(is_just_clicked: bool = false) -> void:
	var mouse_pos = get_global_mouse_position()
	var grid_pos = layer_floor.local_to_map(mouse_pos)
	var has_grass = layer_floor.get_cell_source_id(grid_pos) == TileSkinData.GRASS_SOURCE_ID
	var has_wall = layer_wall.get_cell_source_id(grid_pos) == TileSkinData.WALL_SOURCE_ID
	var has_ice = layer_ice.get_cell_source_id(grid_pos) == TileSkinData.ICE_SOURCE_ID
	var is_empty = not has_wall and not has_ice and not has_grass
	var current_theme = cell_themes.get(grid_pos, "")
	var is_trans = current_theme == "_trans"
	var is_bridge = current_theme == "_bridge_v" or current_theme == "_bridge_h"
	if ui_layer.get("is_locked") and ui_layer.is_locked:
		match current_brush:
			TileSkinData.Brush.GRASS:
				if not is_empty and not (has_grass and not is_trans and not is_bridge and not has_ice): return
			TileSkinData.Brush.TRANS:
				if not is_empty and not is_trans: return
			TileSkinData.Brush.BRIDGE:
				if not is_empty and not is_bridge: return
			TileSkinData.Brush.WALL:
				if not is_empty and not has_wall: return
			TileSkinData.Brush.ICE:
				if not is_empty and not has_ice: return
	match current_brush:
		TileSkinData.Brush.GRASS:
			var is_real_grass = has_grass and not is_trans and not is_bridge and not has_ice
			if is_just_clicked:
				if is_trans or is_bridge:
					is_repainting_theme = false
					cell_themes[grid_pos] = "_light"
					layer_floor.set_cell(grid_pos, TileSkinData.GRASS_SOURCE_ID, Vector2i(0,0))
					layer_wall.set_cell(grid_pos, -1)
					layer_ice.set_cell(grid_pos, -1)
					update_smart_area(grid_pos)
				elif is_real_grass:
					is_repainting_theme = true
					var current_grass_theme = cell_themes.get(grid_pos, "_light")
					current_target_theme = "_dark" if current_grass_theme == "_light" else "_light"
					cell_themes[grid_pos] = current_target_theme
					update_smart_area(grid_pos)
				else:
					is_repainting_theme = false
					cell_themes[grid_pos] = "_light"
					layer_floor.set_cell(grid_pos, TileSkinData.GRASS_SOURCE_ID, Vector2i(0,0))
					layer_wall.set_cell(grid_pos, -1)
					layer_ice.set_cell(grid_pos, -1)
					update_smart_area(grid_pos)
			else:
				if is_repainting_theme:
					if is_real_grass and cell_themes.get(grid_pos, "_light") != current_target_theme:
						cell_themes[grid_pos] = current_target_theme
						update_smart_area(grid_pos)
				else:
					if not is_real_grass:
						cell_themes[grid_pos] = "_light"
						layer_floor.set_cell(grid_pos, TileSkinData.GRASS_SOURCE_ID, Vector2i(0,0))
						layer_wall.set_cell(grid_pos, -1)
						layer_ice.set_cell(grid_pos, -1)
						update_smart_area(grid_pos)
		TileSkinData.Brush.ICE:
			if layer_ice.get_cell_source_id(grid_pos) != TileSkinData.ICE_SOURCE_ID:
				apply_custom_cell(layer_ice, grid_pos, TileSkinData.ICE_SOURCE_ID, get_tile_variation(grid_pos, get_skin_element("", "ice"), "ice"))
				layer_floor.set_cell(grid_pos, TileSkinData.GRASS_SOURCE_ID, Vector2i(0,0))
				if not cell_themes.has(grid_pos):
					cell_themes[grid_pos] = "_light"
				layer_wall.set_cell(grid_pos, -1)
				cell_themes.erase(grid_pos)
				update_smart_area(grid_pos)
		TileSkinData.Brush.WALL:
			if layer_wall.get_cell_source_id(grid_pos) != TileSkinData.WALL_SOURCE_ID:
				layer_wall.set_cell(grid_pos, TileSkinData.WALL_SOURCE_ID, Vector2i(0, 0))
				layer_floor.set_cell(grid_pos, -1)
				layer_ice.set_cell(grid_pos, -1)
				cell_themes.erase(grid_pos)
				update_smart_area(grid_pos)
		TileSkinData.Brush.TRANS:
			if current_theme != "_trans":
				cell_themes[grid_pos] = "_trans"
				layer_floor.set_cell(grid_pos, TileSkinData.GRASS_SOURCE_ID, Vector2i(0,0))
				layer_wall.set_cell(grid_pos, -1)
				layer_ice.set_cell(grid_pos, -1)
				update_smart_area(grid_pos)
		TileSkinData.Brush.BRIDGE:
			if is_just_clicked:
				if is_bridge:
					is_repainting_theme = true
					current_target_theme = "_bridge_h" if current_theme == "_bridge_v" else "_bridge_v"
					cell_themes[grid_pos] = current_target_theme
					update_smart_area(grid_pos)
				else:
					is_repainting_theme = false
					cell_themes[grid_pos] = "_bridge_h"
					layer_floor.set_cell(grid_pos, TileSkinData.GRASS_SOURCE_ID, Vector2i(0,0))
					layer_wall.set_cell(grid_pos, -1)
					layer_ice.set_cell(grid_pos, -1)
					update_smart_area(grid_pos)
			else:
				if is_repainting_theme:
					if is_bridge and current_theme != current_target_theme:
						cell_themes[grid_pos] = current_target_theme
						update_smart_area(grid_pos)
				else:
					if not is_bridge:
						cell_themes[grid_pos] = "_bridge_h"
						layer_floor.set_cell(grid_pos, TileSkinData.GRASS_SOURCE_ID, Vector2i(0,0))
						layer_wall.set_cell(grid_pos, -1)
						layer_ice.set_cell(grid_pos, -1)
						update_smart_area(grid_pos)

func _apply_brush_to_layer(grid_pos: Vector2i, target_layer: TileMapLayer, source_id: int) -> void:
	if source_id == TileSkinData.GRASS_SOURCE_ID:
		target_layer.set_cell(grid_pos, source_id, Vector2i(0,0))
		layer_ice.set_cell(grid_pos, -1)
	else:
		apply_custom_cell(target_layer, grid_pos, source_id, get_tile_variation(grid_pos, get_skin_element("", "ice"), "ice"))
		layer_floor.set_cell(grid_pos, TileSkinData.GRASS_SOURCE_ID, Vector2i(0,0))
	layer_wall.set_cell(grid_pos, -1)

func erase_all_layers(specific_pos = null) -> void:
	var grid_pos = specific_pos if specific_pos != null else layer_wall.local_to_map(get_global_mouse_position())
	var has_wall = layer_wall.get_cell_source_id(grid_pos) == TileSkinData.WALL_SOURCE_ID
	var has_ice = layer_ice.get_cell_source_id(grid_pos) == TileSkinData.ICE_SOURCE_ID
	var has_grass = layer_floor.get_cell_source_id(grid_pos) == TileSkinData.GRASS_SOURCE_ID
	var current_theme = cell_themes.get(grid_pos, "")
	var is_trans = current_theme == "_trans"
	var is_bridge = current_theme == "_bridge_v" or current_theme == "_bridge_h"
	
	if ui_layer.get("is_locked") and ui_layer.is_locked:
		var matches_selection = false
		match current_brush:
			TileSkinData.Brush.GRASS:
				matches_selection = (has_grass and not is_trans and not is_bridge and not has_ice)
			TileSkinData.Brush.TRANS:
				matches_selection = is_trans
			TileSkinData.Brush.BRIDGE:
				matches_selection = is_bridge
			TileSkinData.Brush.WALL:
				matches_selection = has_wall
			TileSkinData.Brush.ICE:
				matches_selection = has_ice
		if not matches_selection:
			return
	cell_themes.erase(grid_pos)
	layer_floor.set_cell(grid_pos, -1)
	layer_wall.set_cell(grid_pos, -1)
	layer_ice.set_cell(grid_pos, -1)
	update_smart_area(grid_pos)

func update_smart_area(cell_pos: Vector2i, is_pattern: bool = false) -> void:
	set_active_map(is_pattern)
	var layers_to_clear = [active_persp_up, active_persp_up_wall, active_persp_up_ice, active_persp_right, active_persp_right_wall, active_persp_Eright_wall, active_persp_right_ice, active_persp_Wright, active_persp_Wdown, active_persp_Wleft]
	for x in range(-2, 3):
		for y in range(-2, 3):
			var target_cell = cell_pos + Vector2i(x, y)
			for l in layers_to_clear:
				if l != null: l.set_cell(target_cell, -1)
	for x in range(-3, 4):
		for y in range(-3, 4):
			var target_cell = cell_pos + Vector2i(x, y)
			if get_source_id(active_wall, target_cell) == TileSkinData.WALL_SOURCE_ID:
				apply_bitmask_to_single_cell(target_cell, active_wall, TileSkinData.wall_bitmask_repo, TileSkinData.WALL_SOURCE_ID)
			if get_source_id(active_floor, target_cell) == TileSkinData.GRASS_SOURCE_ID:
				apply_bitmask_to_single_cell(target_cell, active_floor, TileSkinData.grass_bitmask_repo, TileSkinData.GRASS_SOURCE_ID)
			if get_source_id(active_ice, target_cell) == TileSkinData.ICE_SOURCE_ID:
				apply_bitmask_to_single_cell(target_cell, active_ice, TileSkinData.grass_bitmask_repo, TileSkinData.ICE_SOURCE_ID)
	if is_pattern: set_active_map(false)

func is_grass_or_ice(pos: Vector2i) -> bool:
	if active_floor == layer_floor:
		var theme = cell_themes.get(pos)
		if theme == "_trans" or theme == "_bridge_v" or theme == "_bridge_h":
			return false
	return get_source_id(active_floor, pos) == TileSkinData.GRASS_SOURCE_ID

func get_grass_theme(cell_pos: Vector2i) -> String:
	if active_floor == layer_floor:
		var theme = cell_themes.get(cell_pos)
		if theme == "_trans" or theme == "_bridge_v" or theme == "_bridge_h":
			return theme
	if pattern_window.m3_floor != null and active_floor == pattern_window.m3_floor:
		return pattern_window.pattern_cell_themes.get(cell_pos, "_light")
	match grass_mode:
		1: return cell_themes.get(cell_pos, "_light")
		2: return "_light" if posmod(cell_pos.x + cell_pos.y, 2) == 0 else "_dark"
		3:
			if pattern_window.custom_pattern.is_empty():
				return "_light"
			var px = posmod(cell_pos.x, pattern_window.pattern_size.x)
			var py = posmod(cell_pos.y, pattern_window.pattern_size.y)
			return pattern_window.custom_pattern.get(Vector2i(px, py), "_light")
	return "_light"

func apply_bitmask_to_single_cell(cell_pos: Vector2i, layer: TileMapLayer, repo: Dictionary, source_id: int) -> void:
	if layer == null: return
	var theme = get_grass_theme(cell_pos)
	if source_id == TileSkinData.GRASS_SOURCE_ID:
		if theme == "_trans":
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
		var no_up = get_source_id(active_ice, cell_pos + Vector2i.UP) != TileSkinData.ICE_SOURCE_ID and get_source_id(active_wall, cell_pos + Vector2i.UP) != TileSkinData.WALL_SOURCE_ID
		var no_right = get_source_id(active_ice, cell_pos + Vector2i.RIGHT) != TileSkinData.ICE_SOURCE_ID and get_source_id(active_wall, cell_pos + Vector2i.RIGHT) != TileSkinData.WALL_SOURCE_ID
		var no_up_right = get_source_id(active_ice, cell_pos + Vector2i(1, -1)) != TileSkinData.ICE_SOURCE_ID and get_source_id(active_wall, cell_pos + Vector2i(1, -1)) != TileSkinData.WALL_SOURCE_ID
		if no_up: apply_custom_cell(active_persp_up_ice, cell_pos + Vector2i.UP, border_source_id, get_tile_variation(cell_pos, get_skin_element("up_ice", "normal_ice"), "up_ice"))
		if no_right: apply_custom_cell(active_persp_right_ice, cell_pos + Vector2i.RIGHT, border_source_id, get_tile_variation(cell_pos, get_skin_element("right_ice", "ice"), "right_ice"))
		if no_up and no_right and no_up_right: apply_custom_cell(active_persp_up_ice, cell_pos + Vector2i(1, -1), border_source_id, get_tile_variation(cell_pos, get_skin_element("up_ice", "E_ice"), "up_ice_E"))
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
			var has_solid_right = get_source_id(active_wall, cell_pos + Vector2i.RIGHT) == TileSkinData.WALL_SOURCE_ID or is_grass_or_ice(cell_pos + Vector2i.RIGHT)
			if has_solid_right: return 
			var blocked_eright_wall = (
				get_source_id(active_wall, cell_pos + Vector2i.RIGHT) == TileSkinData.WALL_SOURCE_ID or
				is_grass_or_ice(cell_pos + Vector2i.RIGHT) or
				get_source_id(active_wall, cell_pos + Vector2i.DOWN) == TileSkinData.WALL_SOURCE_ID or
				is_grass_or_ice(cell_pos + Vector2i.DOWN) or
				get_source_id(active_wall, cell_pos + Vector2i(1, 1)) == TileSkinData.WALL_SOURCE_ID or
				is_grass_or_ice(cell_pos + Vector2i(1, 1)))
			if typeof(w_data) == TYPE_DICTIONARY:
				for offset in w_data:
					var tex = str(w_data[offset])
					if tex == "Eright_wall" and blocked_eright_wall: continue
					var target_pos = cell_pos + offset
					if tex == "normal":
						var coords_above = get_atlas_coords(active_persp_Wright, target_pos + Vector2i.UP)
						tex = "full" if (coords_above.y == 2 or coords_above.y == 3) else "mini"
					var final_atlas = get_skin_element("water_right", tex, theme)
					apply_custom_cell(active_persp_Wright, target_pos, border_source_id, get_tile_variation(cell_pos, final_atlas, "water_right_" + str(offset)))
			else:
				var tex = str(w_data)
				if not (tex == "Eright_wall" and blocked_eright_wall):
					var target_pos = cell_pos + Vector2i.RIGHT
					if tex == "normal":
						var coords_above = get_atlas_coords(active_persp_Wright, target_pos + Vector2i.UP)
						tex = "full" if (coords_above.y == 2 or coords_above.y == 3) else "mini"
					var final_atlas = get_skin_element("water_right", tex, theme)
					apply_custom_cell(active_persp_Wright, target_pos, border_source_id, get_tile_variation(cell_pos, final_atlas, "water_right"))

		if tile_data.has("persp_down_water") and tile_data["persp_down_water"] != null:
			var data = tile_data["persp_down_water"]
			if typeof(data) == TYPE_DICTIONARY:
				for offset in data:
					var final_atlas = get_skin_element("water_down", str(data[offset]), theme)
					apply_custom_cell(active_persp_Wdown, cell_pos + offset, border_source_id, get_tile_variation(cell_pos, final_atlas, "persp_down_water_" + str(offset)))
			else:
				var final_atlas = get_skin_element("water_down", str(data), theme)
				apply_custom_cell(active_persp_Wdown, cell_pos + Vector2i.DOWN, border_source_id, get_tile_variation(cell_pos, final_atlas, "persp_down_water"))

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
					apply_custom_cell(active_persp_up, cell_pos + offset, border_source_id, get_tile_variation(cell_pos, final_atlas, "persp_up_" + str(offset)))
			else:
				var final_atlas = get_skin_element("up", str(data), theme)
				apply_custom_cell(active_persp_up, cell_pos + Vector2i.UP, border_source_id, get_tile_variation(cell_pos, final_atlas, "persp_up"))

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
						var coords_above = get_atlas_coords(active_persp_Wleft, target_pos + Vector2i.UP)
						tex = "full" if (coords_above.y == 2 or coords_above.y == 3) else "mini"
					var final_atlas = get_skin_element("water_left", tex, theme)
					apply_custom_cell(active_persp_Wleft, target_pos, border_source_id, get_tile_variation(cell_pos, final_atlas, "persp_left_water_" + str(offset)))
			else:
				var tex = str(data)
				var target_pos = cell_pos + Vector2i.LEFT
				if tex == "mini" or tex == "full":
					var coords_above = get_atlas_coords(active_persp_Wleft, target_pos + Vector2i.UP)
					tex = "full" if (coords_above.y == 2 or coords_above.y == 3) else "mini"
				var final_atlas = get_skin_element("water_left", tex, theme)
				apply_custom_cell(active_persp_Wleft, target_pos, border_source_id, get_tile_variation(cell_pos, final_atlas, "persp_left_water"))

		if tile_data.has("persp_right") and tile_data["persp_right"] != null:
			var data = tile_data["persp_right"]
			process_water_right.call(data)
			if source_id != TileSkinData.ICE_SOURCE_ID:
				if typeof(data) == TYPE_DICTIONARY:
					for offset in data:
						var final_atlas = get_skin_element("right", str(data[offset]), theme)
						apply_custom_cell(active_persp_right, cell_pos + offset, border_source_id, get_tile_variation(cell_pos, final_atlas, "persp_right_" + str(offset)))
				else:
					var final_atlas = get_skin_element("right", str(data), theme)
					apply_custom_cell(active_persp_right, cell_pos + Vector2i.RIGHT, border_source_id, get_tile_variation(cell_pos, final_atlas, "persp_right"))

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
						apply_custom_cell(active_persp_Eright_wall, target_pos, border_source_id, get_tile_variation(cell_pos, final_atlas, "persp_Eright_wall_" + str(offset)))
					else:
						apply_custom_cell(active_persp_right_wall, target_pos, border_source_id, get_tile_variation(cell_pos, final_atlas, "persp_right_wall_" + str(offset)))
			else:
				var tex = str(data)
				var final_atlas = get_skin_element("right_wall", tex, theme)
				var target_pos = cell_pos + Vector2i.RIGHT
				if tex == "Eright_wall":
					apply_custom_cell(active_persp_Eright_wall, target_pos, border_source_id, get_tile_variation(cell_pos, final_atlas, "persp_Eright_wall"))
				else:
					apply_custom_cell(active_persp_right_wall, target_pos, border_source_id, get_tile_variation(cell_pos, final_atlas, "persp_right_wall"))

		if tile_data.has("persp_up_wall") and tile_data["persp_up_wall"] != null:
			var data = tile_data["persp_up_wall"]
			if typeof(data) == TYPE_DICTIONARY:
				for offset in data:
					var final_atlas = get_skin_element("up_wall", str(data[offset]), theme)
					apply_custom_cell(active_persp_up_wall, cell_pos + offset, border_source_id, get_tile_variation(cell_pos, final_atlas, "persp_up_wall_" + str(offset)))
			else:
				var final_atlas = get_skin_element("up_wall", str(data), theme)
				apply_custom_cell(active_persp_up_wall, cell_pos + Vector2i.UP, border_source_id, get_tile_variation(cell_pos, final_atlas, "persp_up_wall"))

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
		return is_grass_or_ice(pos) or get_source_id(active_wall, pos) == TileSkinData.WALL_SOURCE_ID
	return get_source_id(layer, pos) == base_source_id

func play_map():
	player = PLAYER_SCENE.instantiate()
	player.position = Vector2.ZERO
	player.z_index = 5
	add_child(player)
	var player_camera = player.get_node_or_null("Camera2D")
	if player_camera != null:
		player_camera.make_current()

func back_to_editor():
	player.queue_free()
	camera.make_current()
