extends Node2D

@onready var map_node: Node2D = $MAP
@onready var layer_floor: TileMapLayer = %tileMapLayer_floor
@onready var layer_wall: TileMapLayer = %tileMapLayer_wall
@onready var layer_ice: TileMapLayer = %tileMapLayer_ice
@onready var layer_persp_right: TileMapLayer = %TileMapLayer_perspective_right
@onready var layer_persp_right_wall: TileMapLayer = %TileMapLayer_perspective_right_wall
@onready var layer_persp_right_ice: TileMapLayer = %TileMapLayer_perspective_right_ice
@onready var layer_persp_up: TileMapLayer = %TileMapLayer_perspective_up
@onready var layer_persp_up_wall: TileMapLayer = %TileMapLayer_perspective_up_wall
@onready var layer_persp_up_ice: TileMapLayer = %TileMapLayer_perspective_up_ice
@onready var layer_persp_Wright: TileMapLayer = %TileMapLayer_perspective_water_right
@onready var layer_persp_Wdown: TileMapLayer = %TileMapLayer_perspective_water_down
@onready var layer_persp_Wleft: TileMapLayer = %TileMapLayer_perspective_water_left

@onready var mode3_node: Node2D = %PatternWindow/Mode3
@onready var m3_floor: TileMapLayer = %M3_floor
@onready var m3_persp_right: TileMapLayer = %M3_perspective_right
@onready var m3_persp_up: TileMapLayer = %M3_perspective_up
@onready var m3_water_right: TileMapLayer = %M3_water_right
@onready var m3_water_down: TileMapLayer = %M3_water_down
@onready var m3_water_left: TileMapLayer = %M3_water_left
@onready var m3_gridvisualizer: Node2D = $UI_Layer/PatternWindow/Mode3/GridVisualizer

@onready var camera: Camera2D = $Camera2D
@onready var lbl_coords: Label = $UI_Layer/Coordonnees
@onready var lbl_grass_mode: Label = $UI_Layer/grass_mode/Label

@onready var btn_mode3: Button = %Btn_Mode3
@onready var pattern_window: Window = %PatternWindow

@onready var grass_mode: int = int(lbl_grass_mode.text)

var active_floor: TileMapLayer
var active_wall: TileMapLayer
var active_ice: TileMapLayer
var active_persp_right: TileMapLayer
var active_persp_right_wall: TileMapLayer
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

var pattern_cell_themes: Dictionary = {} 
var custom_pattern: Dictionary = {} 
var pattern_size: Vector2i = Vector2i(1, 1) 
var is_panning_pattern: bool = false
var pattern_zoom: float = 1.0

var current_brush: TileSkinData.Brush = TileSkinData.Brush.GRASS
var current_skin_name: String = "Normal"

var is_panning: bool = false
var zoom_min: float = 0.2
var zoom_max: float = 3.0
var zoom_speed: float = 0.1

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
	var btn_herbe = $UI_Layer/PanelContainer/HBoxContainer/Btn_Herbe
	var btn_mur = $UI_Layer/PanelContainer/HBoxContainer/Btn_Mur
	var btn_glace = $UI_Layer/PanelContainer/HBoxContainer/Btn_Glace
	var brush_group = ButtonGroup.new()
	btn_herbe.button_group = brush_group
	btn_mur.button_group = brush_group
	btn_glace.button_group = brush_group
	btn_herbe.pressed.connect(func(): current_brush = TileSkinData.Brush.GRASS)
	btn_mur.pressed.connect(func(): current_brush = TileSkinData.Brush.WALL)
	btn_glace.pressed.connect(func(): current_brush = TileSkinData.Brush.ICE)
	btn_herbe.button_pressed = true
	pattern_window.hide()
	btn_mode3.hide()
	pattern_window.unresizable = false
	pattern_window.borderless = false
	pattern_window.close_requested.connect(func(): pattern_window.hide())
	pattern_window.window_input.connect(_on_pattern_window_input)
	if not btn_mode3.pressed.is_connected(_on_mode3_pressed):
		btn_mode3.pressed.connect(_on_mode3_pressed)

func _process(_delta: float) -> void:
	var center_pixel_pos = camera.global_position
	var center_grid_pos = layer_floor.local_to_map(center_pixel_pos)
	lbl_coords.text = "X: %d, Y: %d" % [center_grid_pos.x, center_grid_pos.y]
	if pattern_window.visible and m3_gridvisualizer:
		m3_gridvisualizer.queue_redraw()

func _on_grass_mode_pressed() -> void:
	if grass_mode == 3:
		grass_mode = 1
	else:
		grass_mode += 1
	lbl_grass_mode.text = str(grass_mode)
	if grass_mode == 3:
		btn_mode3.show()
	else:
		btn_mode3.hide()
		pattern_window.hide()
	refresh_all_grass()

func _on_mode3_pressed() -> void:
	pattern_window.visible = not pattern_window.visible
	if pattern_window.visible:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE) 
		current_brush = TileSkinData.Brush.GRASS
		$UI_Layer/PanelContainer/HBoxContainer/Btn_Herbe.button_pressed = true

func _on_pattern_window_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_MIDDLE:
			is_panning_pattern = event.pressed
		elif event.pressed:
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				pattern_zoom = clamp(pattern_zoom + zoom_speed, zoom_min, zoom_max)
				mode3_node.scale = Vector2(pattern_zoom, pattern_zoom)
			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				pattern_zoom = clamp(pattern_zoom - zoom_speed, zoom_min, zoom_max)
				mode3_node.scale = Vector2(pattern_zoom, pattern_zoom)
	if event is InputEventMouseMotion:
		if is_panning_pattern:
			mode3_node.position += event.relative
			return
	if event is InputEventMouseMotion or event is InputEventMouseButton:
		var is_left = Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
		var is_right = Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT)
		var is_just_clicked = event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed
		if is_left and not is_panning_pattern:
			paint_pattern_tile(is_just_clicked)
		elif is_right and not is_panning_pattern:
			erase_pattern_tile()

func paint_pattern_tile(is_just_clicked: bool) -> void:
	var grid_pos = m3_floor.local_to_map(mode3_node.get_local_mouse_position())
	var has_grass = pattern_cell_themes.has(grid_pos)
	if is_just_clicked:
		if has_grass:
			is_repainting_theme = true
			if pattern_cell_themes.get(grid_pos, "_light"):
				current_target_theme = "_dark"
			else:
				current_target_theme = "_light"
			pattern_cell_themes[grid_pos] = current_target_theme
		else:
			is_repainting_theme = false
			pattern_cell_themes[grid_pos] = "_light"
	else:
		if is_repainting_theme:
			if has_grass and pattern_cell_themes.get(grid_pos, "_light") != current_target_theme:
				pattern_cell_themes[grid_pos] = current_target_theme
		else:
			if not has_grass:
				pattern_cell_themes[grid_pos] = "_light"
	update_pattern_rectangle(null)

func erase_pattern_tile() -> void:
	var grid_pos = m3_floor.local_to_map(mode3_node.get_local_mouse_position())
	if pattern_cell_themes.has(grid_pos):
		update_pattern_rectangle(grid_pos)

func update_pattern_rectangle(erased_pos: Variant) -> void:
	var used_cells = pattern_cell_themes.keys()
	if used_cells.is_empty():
		pattern_size = Vector2i(1, 1)
		custom_pattern.clear()
		_clear_and_redraw_pattern_visuals()
		return
	var min_x = used_cells[0].x
	var max_x = used_cells[0].x
	var min_y = used_cells[0].y
	var max_y = used_cells[0].y
	for cell in used_cells:
		if cell.x < min_x: min_x = cell.x
		if cell.x > max_x: max_x = cell.x
		if cell.y < min_y: min_y = cell.y
		if cell.y > max_y: max_y = cell.y
	if erased_pos != null and typeof(erased_pos) == TYPE_VECTOR2I:
		var shrink_left = (erased_pos.x == min_x)
		var shrink_right = (erased_pos.x == max_x)
		var shrink_top = (erased_pos.y == min_y)
		var shrink_bottom = (erased_pos.y == max_y)
		if min_x == max_x or min_y == max_y:
			pattern_cell_themes.erase(erased_pos)
			used_cells = pattern_cell_themes.keys()
			if used_cells.is_empty():
				pattern_size = Vector2i(1, 1)
				custom_pattern.clear()
				_clear_and_redraw_pattern_visuals()
				return
			min_x = used_cells[0].x; max_x = used_cells[0].x
			min_y = used_cells[0].y; max_y = used_cells[0].y
			for cell in used_cells:
				if cell.x < min_x: min_x = cell.x
				if cell.x > max_x: max_x = cell.x
				if cell.y < min_y: min_y = cell.y
				if cell.y > max_y: max_y = cell.y
		elif shrink_left or shrink_right or shrink_top or shrink_bottom:
			var cells_to_remove = []
			for cell in used_cells:
				if (shrink_left and cell.x == min_x) or \
				   (shrink_right and cell.x == max_x) or \
				   (shrink_top and cell.y == min_y) or \
				   (shrink_bottom and cell.y == max_y):
					cells_to_remove.append(cell)
			for c in cells_to_remove:
				pattern_cell_themes.erase(c)
			used_cells = pattern_cell_themes.keys()
			if used_cells.is_empty():
				pattern_size = Vector2i(1, 1)
				custom_pattern.clear()
				_clear_and_redraw_pattern_visuals()
				return
			min_x = used_cells[0].x
			max_x = used_cells[0].x
			min_y = used_cells[0].y
			max_y = used_cells[0].y
			for cell in used_cells:
				if cell.x < min_x: min_x = cell.x
				if cell.x > max_x: max_x = cell.x
				if cell.y < min_y: min_y = cell.y
				if cell.y > max_y: max_y = cell.y
		else:
			pattern_cell_themes[erased_pos] = "_light"
	for x in range(min_x, max_x + 1):
		for y in range(min_y, max_y + 1):
			var pos = Vector2i(x, y)
			if not pattern_cell_themes.has(pos):
				pattern_cell_themes[pos] = "_light"
	pattern_size = Vector2i(max_x - min_x + 1, max_y - min_y + 1)
	custom_pattern.clear()
	for x in range(pattern_size.x):
		for y in range(pattern_size.y):
			var global_c = Vector2i(min_x + x, min_y + y)
			custom_pattern[Vector2i(x, y)] = pattern_cell_themes.get(global_c, "_light")
	_clear_and_redraw_pattern_visuals()

func _clear_and_redraw_pattern_visuals() -> void:
	m3_floor.clear()
	m3_persp_up.clear()
	m3_persp_right.clear()
	m3_water_right.clear()
	m3_water_down.clear()
	m3_water_left.clear()
	for pos in pattern_cell_themes.keys():
		m3_floor.set_cell(pos, TileSkinData.GRASS_SOURCE_ID, Vector2i(0,0))
	for pos in pattern_cell_themes.keys():
		set_active_map(true)
		apply_bitmask_to_single_cell(pos, m3_floor, TileSkinData.grass_bitmask_repo, TileSkinData.GRASS_SOURCE_ID)
		set_active_map(false)
	refresh_all_grass()

func set_active_map(is_pattern: bool) -> void:
	if is_pattern:
		active_floor = m3_floor
		active_wall = null 
		active_ice = null  
		active_persp_right = m3_persp_right
		active_persp_right_wall = null
		active_persp_right_ice = null
		active_persp_up = m3_persp_up
		active_persp_up_wall = null
		active_persp_up_ice = null
		active_persp_Wright = m3_water_right
		active_persp_Wdown = m3_water_down
		active_persp_Wleft = m3_water_left
	else:
		active_floor = layer_floor
		active_wall = layer_wall
		active_ice = layer_ice
		active_persp_right = layer_persp_right
		active_persp_right_wall = layer_persp_right_wall
		active_persp_right_ice = layer_persp_right_ice
		active_persp_up = layer_persp_up
		active_persp_up_wall = layer_persp_up_wall
		active_persp_up_ice = layer_persp_up_ice
		active_persp_Wright = layer_persp_Wright
		active_persp_Wdown = layer_persp_Wdown
		active_persp_Wleft = layer_persp_Wleft

func refresh_all_grass() -> void:
	var was_pattern = (active_floor == m3_floor)
	set_active_map(false)
	var used_cells = layer_floor.get_used_cells()
	for cell in used_cells:
		apply_bitmask_to_single_cell(cell, layer_floor, TileSkinData.grass_bitmask_repo, TileSkinData.GRASS_SOURCE_ID)
	set_active_map(was_pattern)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.is_echo():
		if event.keycode == KEY_0 or event.keycode == KEY_KP_0:
			camera.global_position = Vector2.ZERO
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_MIDDLE:
			is_panning = event.pressed
		elif event.pressed:
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				apply_zoom(zoom_speed)
			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				apply_zoom(-zoom_speed)
	if event is InputEventMouseMotion:
		if is_panning:
			camera.position -= event.relative / camera.zoom
			return 
	if event is InputEventMouseMotion or event is InputEventMouseButton:
		var is_left_clicking = Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
		var is_right_clicking = Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT)
		var is_just_clicked = false
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			is_just_clicked = true
			
		if is_left_clicking and not is_panning:
			paint_smart_tile(is_just_clicked)
		elif is_right_clicking and not is_panning:
			erase_all_layers()

func apply_zoom(amount: float) -> void:
	var current_zoom = camera.zoom.x
	var new_zoom = clamp(current_zoom + amount, zoom_min, zoom_max)
	camera.zoom = Vector2(new_zoom, new_zoom)

func paint_smart_tile(is_just_clicked: bool = false) -> void:
	var mouse_pos = get_global_mouse_position()
	var grid_pos = layer_floor.local_to_map(mouse_pos)
	
	match current_brush:
		TileSkinData.Brush.GRASS:
			var has_grass = layer_floor.get_cell_source_id(grid_pos) == TileSkinData.GRASS_SOURCE_ID
			if is_just_clicked:
				if has_grass:
					is_repainting_theme = true
					var current_theme = cell_themes.get(grid_pos, "_light")
					current_target_theme = "_dark" if current_theme == "_light" else "_light"
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
					if has_grass and cell_themes.get(grid_pos, "_light") != current_target_theme:
						cell_themes[grid_pos] = current_target_theme
						update_smart_area(grid_pos)
				else:
					if not has_grass:
						cell_themes[grid_pos] = "_light"
						layer_floor.set_cell(grid_pos, TileSkinData.GRASS_SOURCE_ID, Vector2i(0,0))
						layer_wall.set_cell(grid_pos, -1)
						layer_ice.set_cell(grid_pos, -1)
						update_smart_area(grid_pos)
		TileSkinData.Brush.ICE:
			apply_custom_cell(layer_ice, grid_pos, TileSkinData.ICE_SOURCE_ID, get_tile_variation(grid_pos, get_skin_element("", "ice"), "ice"))
			layer_floor.set_cell(grid_pos, -1)
			layer_wall.set_cell(grid_pos, -1)
			update_smart_area(grid_pos)
		TileSkinData.Brush.WALL:
			layer_wall.set_cell(grid_pos, TileSkinData.WALL_SOURCE_ID, Vector2i(0, 0))
			layer_floor.set_cell(grid_pos, -1)
			layer_ice.set_cell(grid_pos, -1)
			cell_themes.erase(grid_pos)
			update_smart_area(grid_pos)

func erase_all_layers(specific_pos = null) -> void:
	var grid_pos = specific_pos if specific_pos != null else layer_wall.local_to_map(get_global_mouse_position())
	cell_themes.erase(grid_pos)
	layer_floor.set_cell(grid_pos, -1)
	layer_wall.set_cell(grid_pos, -1)
	layer_ice.set_cell(grid_pos, -1)
	update_smart_area(grid_pos)

func update_smart_area(cell_pos: Vector2i) -> void:
	set_active_map(false)
	for x in range(-2, 3):
		for y in range(-2, 3):
			var target_cell = cell_pos + Vector2i(x, y)
			layer_persp_up.set_cell(target_cell, -1)
			layer_persp_up_wall.set_cell(target_cell, -1)
			layer_persp_up_ice.set_cell(target_cell, -1)
			layer_persp_right.set_cell(target_cell, -1)
			layer_persp_right_wall.set_cell(target_cell, -1)
			layer_persp_right_ice.set_cell(target_cell, -1)
			layer_persp_Wright.set_cell(target_cell, -1)
			layer_persp_Wdown.set_cell(target_cell, -1)
			layer_persp_Wleft.set_cell(target_cell, -1)
			
	for x in range(-3, 4):
		for y in range(-3, 4):
			var target_cell = cell_pos + Vector2i(x, y)
			if layer_wall.get_cell_source_id(target_cell) == TileSkinData.WALL_SOURCE_ID:
				apply_bitmask_to_single_cell(target_cell, layer_wall, TileSkinData.wall_bitmask_repo, TileSkinData.WALL_SOURCE_ID)
			if layer_floor.get_cell_source_id(target_cell) == TileSkinData.GRASS_SOURCE_ID:
				apply_bitmask_to_single_cell(target_cell, layer_floor, TileSkinData.grass_bitmask_repo, TileSkinData.GRASS_SOURCE_ID)
			if layer_ice.get_cell_source_id(target_cell) == TileSkinData.ICE_SOURCE_ID:
				apply_bitmask_to_single_cell(target_cell, layer_ice, TileSkinData.grass_bitmask_repo, TileSkinData.ICE_SOURCE_ID)

func is_grass_or_ice(pos: Vector2i) -> bool:
	return get_source_id(active_floor, pos) == TileSkinData.GRASS_SOURCE_ID or get_source_id(active_ice, pos) == TileSkinData.ICE_SOURCE_ID

func get_grass_theme(cell_pos: Vector2i) -> String:
	if active_floor == m3_floor:
		return pattern_cell_themes.get(cell_pos, "_light")
		
	match grass_mode:
		1:
			return cell_themes.get(cell_pos, "_light")
		2:
			if posmod(cell_pos.x + cell_pos.y, 2) == 0:
				return "_light"
			else:
				return "_dark"
		3:
			if custom_pattern.is_empty():
				return "_light"
			var px = posmod(cell_pos.x, pattern_size.x)
			var py = posmod(cell_pos.y, pattern_size.y)
			return custom_pattern.get(Vector2i(px, py), "_light")
	return "_light"

func apply_bitmask_to_single_cell(cell_pos: Vector2i, layer: TileMapLayer, repo: Dictionary, source_id: int) -> void:
	if layer == null: return
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
	var theme = get_grass_theme(cell_pos)
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
				is_grass_or_ice(cell_pos + Vector2i(1, 1))
			)
			
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
					var final_atlas = get_skin_element("right_wall", str(data[offset]), theme)
					apply_custom_cell(active_persp_right_wall, cell_pos + offset, border_source_id, get_tile_variation(cell_pos, final_atlas, "persp_right_wall_" + str(offset)))
			else:
				var final_atlas = get_skin_element("right_wall", str(data), theme)
				apply_custom_cell(active_persp_right_wall, cell_pos + Vector2i.RIGHT, border_source_id, get_tile_variation(cell_pos, final_atlas, "persp_right_wall"))

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
