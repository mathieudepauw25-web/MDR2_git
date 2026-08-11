extends Window

var main_node: Node2D 

var is_panning_pattern: bool = false
var pattern_zoom: float = 1.0
var zoom_min: float = 0.2
var zoom_max: float = 3.0
var zoom_speed: float = 0.1

var pattern_cell_themes: Dictionary = {} 
var custom_pattern: Dictionary = {} 
var pattern_size: Vector2i = Vector2i(1, 1) 
var is_repainting_theme: bool = false
var current_target_theme: String = ""

@onready var mode3_node: Node2D = $Mode3
@onready var m3_floor: TileMapLayer = $Mode3/M3_floor
@onready var m3_persp_right: TileMapLayer = $Mode3/M3_perspective_right
@onready var m3_persp_up: TileMapLayer = $Mode3/M3_perspective_up
@onready var m3_water_right: TileMapLayer = $Mode3/M3_water_right
@onready var m3_water_down: TileMapLayer = $Mode3/M3_water_down
@onready var m3_water_left: TileMapLayer = $Mode3/M3_water_left
@onready var m3_gridvisualizer: Node2D = $Mode3/GridVisualizer

func _ready():
	add_theme_font_size_override("title_font_size", 3)
	add_theme_constant_override("resize_margin", 8) 
	var style_border = StyleBoxFlat.new()
	style_border.bg_color = Color(0.102, 0.541, 0.176, 1.0) 
	style_border.expand_margin_top = 8
	style_border.expand_margin_left = 1
	style_border.expand_margin_right = 1
	style_border.expand_margin_bottom = 1
	add_theme_stylebox_override("embedded_border", style_border)
	add_theme_constant_override("close_h_offset", 25)
	add_theme_constant_override("close_v_offset", 20)
	close_requested.connect(func(): hide())
	window_input.connect(_on_window_input)
	if m3_gridvisualizer:
		m3_gridvisualizer.draw.connect(_on_gridvisualizer_draw)

func _on_gridvisualizer_draw() -> void:
	var grid_size: int = 16
	var line_color = Color(1.0, 1.0, 1.0, 0.2)
	var start_pos = -mode3_node.position / mode3_node.scale
	var end_pos = (Vector2(size) - mode3_node.position) / mode3_node.scale
	var start_x = floor(start_pos.x / grid_size) * grid_size
	var start_y = floor(start_pos.y / grid_size) * grid_size
	var x = start_x
	while x <= end_pos.x:
		m3_gridvisualizer.draw_line(Vector2(x, start_pos.y), Vector2(x, end_pos.y), line_color)
		x += grid_size
	var y = start_y
	while y <= end_pos.y:
		m3_gridvisualizer.draw_line(Vector2(start_pos.x, y), Vector2(end_pos.x, y), line_color)
		y += grid_size

func _process(_delta: float) -> void:
	if visible and m3_gridvisualizer:
		m3_gridvisualizer.queue_redraw()

func _on_window_input(event: InputEvent) -> void:
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
			current_target_theme = "_dark" if pattern_cell_themes.get(grid_pos, "_light") == "_light" else "_light"
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

func _get_pattern_bounds(cells: Array) -> Rect2i:
	if cells.is_empty(): return Rect2i()
	var min_x = cells[0].x; var max_x = cells[0].x
	var min_y = cells[0].y; var max_y = cells[0].y
	for cell in cells:
		if cell.x < min_x: min_x = cell.x
		elif cell.x > max_x: max_x = cell.x
		if cell.y < min_y: min_y = cell.y
		elif cell.y > max_y: max_y = cell.y
	return Rect2i(min_x, min_y, max_x - min_x + 1, max_y - min_y + 1)

func update_pattern_rectangle(erased_pos: Variant) -> void:
	var used_cells = pattern_cell_themes.keys()
	if used_cells.is_empty():
		_reset_pattern()
		return
	var bounds = _get_pattern_bounds(used_cells)
	if erased_pos != null and typeof(erased_pos) == TYPE_VECTOR2I:
		var is_edge = (erased_pos.x == bounds.position.x or erased_pos.x == bounds.end.x - 1 or 
					   erased_pos.y == bounds.position.y or erased_pos.y == bounds.end.y - 1)
		if bounds.size.x == 1 or bounds.size.y == 1:
			pattern_cell_themes.erase(erased_pos)
			used_cells = pattern_cell_themes.keys()
			if used_cells.is_empty():
				_reset_pattern()
				return
			bounds = _get_pattern_bounds(used_cells)
		elif is_edge:
			var cells_to_remove = []
			for cell in used_cells:
				var on_target_x = (erased_pos.x == bounds.position.x and cell.x == bounds.position.x) or (erased_pos.x == bounds.end.x - 1 and cell.x == bounds.end.x - 1)
				var on_target_y = (erased_pos.y == bounds.position.y and cell.y == bounds.position.y) or (erased_pos.y == bounds.end.y - 1 and cell.y == bounds.end.y - 1)
				if on_target_x or on_target_y:
					cells_to_remove.append(cell)
			for c in cells_to_remove:
				pattern_cell_themes.erase(c)
			used_cells = pattern_cell_themes.keys()
			if used_cells.is_empty():
				_reset_pattern()
				return
			bounds = _get_pattern_bounds(used_cells)
		else:
			pattern_cell_themes[erased_pos] = "_light"
	for x in range(bounds.position.x, bounds.end.x):
		for y in range(bounds.position.y, bounds.end.y):
			var pos = Vector2i(x, y)
			if not pattern_cell_themes.has(pos):
				pattern_cell_themes[pos] = "_light"
	pattern_size = bounds.size
	custom_pattern.clear()
	for x in range(pattern_size.x):
		for y in range(pattern_size.y):
			var global_c = Vector2i(bounds.position.x + x, bounds.position.y + y)
			custom_pattern[Vector2i(x, y)] = pattern_cell_themes.get(global_c, "_light")
	_clear_and_redraw_pattern_visuals()

func _reset_pattern() -> void:
	pattern_size = Vector2i(1, 1)
	custom_pattern.clear()
	_clear_and_redraw_pattern_visuals()

func _clear_and_redraw_pattern_visuals() -> void:
	if not main_node: return
	var pattern_layers = [m3_floor, m3_persp_up, m3_persp_right, m3_water_right, m3_water_down, m3_water_left]
	for l in pattern_layers:
		if l: l.clear()
	for pos in pattern_cell_themes.keys():
		m3_floor.set_cell(pos, TileSkinData.GRASS_SOURCE_ID, Vector2i(0,0))
	main_node.set_active_map(true)
	var tile_manager = main_node.get_node_or_null("TileManager")
	if tile_manager:
		for pos in pattern_cell_themes.keys():
			tile_manager.apply_bitmask_to_single_cell(pos, m3_floor, TileSkinData.grass_bitmask_repo, TileSkinData.GRASS_SOURCE_ID)
		for pos in pattern_cell_themes.keys():
			tile_manager.apply_bitmask_to_single_cell(pos, m3_floor, TileSkinData.grass_bitmask_repo, TileSkinData.GRASS_SOURCE_ID)
	main_node.set_active_map(false)
	if tile_manager:
		tile_manager.refresh_all_grass()
