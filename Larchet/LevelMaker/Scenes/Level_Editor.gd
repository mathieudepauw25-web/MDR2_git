extends Node2D

@onready var map_node: Node2D = $MAP
@onready var layer_floor: TileMapLayer = %tileMapLayer_floor
@onready var layer_wall: TileMapLayer = %tileMapLayer_wall
@onready var layer_persp_right: TileMapLayer = %TileMapLayer_perspective_right
@onready var layer_persp_right_wall: TileMapLayer = %TileMapLayer_perspective_right_wall
@onready var layer_persp_down: TileMapLayer = %TileMapLayer_perspective_down
@onready var layer_persp_left: TileMapLayer = %TileMapLayer_perspective_left
@onready var layer_persp_up: TileMapLayer = %TileMapLayer_perspective_up
@onready var layer_persp_up_wall: TileMapLayer = %TileMapLayer_perspective_up_wall

@onready var camera: Camera2D = $Camera2D
@onready var lbl_coords: Label = $UI_Layer/Coordonnees

var is_repainting_theme: bool = false
var current_target_theme: String = ""
var cell_themes: Dictionary = {}

enum Brush {GRASS, WALL, ICE, ERASER}
var current_brush: Brush = Brush.GRASS
var is_panning: bool = false

var zoom_min: float = 0.2
var zoom_max: float = 3.0
var zoom_speed: float = 0.1

const WALL_SOURCE_ID: int = 0
const GRASS_SOURCE_ID: int = 1
const ICE_SOURCE_ID: int = 2

const dicFloor: Dictionary = {
	"dark" : [Vector2i(1,1),Vector2i(3,1),Vector2i(5,1),Vector2i(7,1)],
	"light" : [Vector2i(1,5),Vector2i(3,5),Vector2i(5,5),Vector2i(7,5)]
}

const dicWall: Dictionary = {
	"normal" : [Vector2i(0,1),Vector2i(2,1)],
	"full" : [Vector2i(6,3),Vector2i(7,3),Vector2i(8,3)]
}

const dicRightWall: Dictionary = {
	"side_wall" : [Vector2i(2,2),Vector2i(3,2)],
	"full_wall" : [Vector2i(1,1),Vector2i(3,1)],
	"mini_wall" : [Vector2i(0,2),Vector2i(1,2)],
	"Eright_wall" : Vector3i(1,4,1)
}

const dicUpWall: Dictionary = {
	"Ewall" : [Vector2i(1,0),Vector2i(3,0)],
	"wall" : [Vector2i(0,0),Vector2i(2,0),Vector2i(9,2)]
}

const dicLeft: Dictionary = {
	"full" : Vector3i(4,2,1),
	"mini" : Vector3i(4,3,1),
	"Eleft" : Vector3i(4,4,1)
}

const dicDown: Dictionary = {
	"down_grass" : [Vector2i(0,0),Vector2i(1,0),Vector2i(2,0),Vector2i(3,0)],
	"down_wall" : [Vector3i(0,1,1),Vector3i(1,1,1),Vector3i(2,1,1),Vector3i(3,1,1)],
	"Eright_grass" : Vector2i(0,4)
}

const dicRight: Dictionary = {
	"full_dark" : [Vector2i(1,2),Vector2i(2,2),Vector2i(3,2),Vector2i(1,3)],
	"full_light" : [Vector2i(2,3),Vector2i(3,3),Vector2i(2,4),Vector2i(3,4)],
	"mini_dark" : [Vector2i(0,5),Vector2i(1,5),Vector2i(2,5),Vector2i(0,6)],
	"mini_light" : [Vector2i(1,6),Vector2i(2,6),Vector2i(1,7),Vector2i(2,7)],
	"full" : Vector2i(0,2),
	"mini" : Vector2i(0,3)
}

const dicUp: Dictionary = {
	"normal_dark" : [Vector2i(3,5),Vector2i(4,5),Vector2i(5,5),Vector2i(6,5)],
	"normal_light" : [Vector2i(3,6),Vector2i(4,6),Vector2i(5,6),Vector2i(6,6)],
	"E_dark" : Vector2i(5,4),
	"E_light" : Vector2i(6,4)
}

const grass_bitmask_repo: Dictionary = {
	0: [{"persp_down": { Vector2i(0,1) : "down_grass", Vector2i(1,1) : "Eright_grass" },
		 "persp_left": { Vector2i(-1,0) : "mini", Vector2i(-1,1) : "Eleft" },
		 "persp_right": "mini", "persp_up": "normal"}],
	1: [{"persp_down": { Vector2i(0,1) : "down_grass", Vector2i(1,1) : "Eright_grass" },
		 "persp_left": { Vector2i(-1,0) : "full", Vector2i(-1,1) : "Eleft" },
		 "persp_right": "full"}],
	2: [{"persp_down": { Vector2i(0,1) : "down_grass" },
		 "persp_left": { Vector2i(-1,0) : "mini", Vector2i(-1,1) : "Eleft"},
		 "persp_up": "normal"}],
	3: [{"persp_down": { Vector2i(0,1) : "down_grass" },
		 "persp_left": { Vector2i(-1,0) : "full", Vector2i(-1,1) : "Eleft" }}],
	4: [{"persp_left": { Vector2i(-1,0) : "mini" },
		 "persp_right": "mini", "persp_up": "normal"}],
	5: [{"persp_left": { Vector2i(-1,0) : "full" }, "persp_right": "full"}],
	6: [{"persp_left": "mini", "persp_up": "normal"}],
	7: [{"persp_left": { Vector2i(-1,0) : "full" }}],
	8: [{"persp_down": { Vector2i(0,1) : "down_grass", Vector2i(1,1) : "Eright_grass" },
		 "persp_right": "mini", "persp_up": "normal"}],
	9: [{"persp_down": { Vector2i(0,1) : "down_grass", Vector2i(1,1) : "Eright_grass" },
		 "persp_right": "full"}],
	10: [{"persp_down": "down_grass", "persp_up": "normal"}],
	11: [{"persp_down": "down_grass"}],
	12: [{"persp_right": "mini", "persp_up": "normal"}],
	13: [{"persp_right": "full"}],
	14: [{"persp_up": "normal"}]
}

const wall_bitmask_repo: Dictionary = {
	0: [{"main": dicWall["normal"],
		 "persp_down": "down_wall",
		 "persp_left": { Vector2i(-1,0) : "mini", Vector2i(-1,1) : "Eleft" },
		 "persp_right_wall": { Vector2i(1,0) : "mini_wall", Vector2i(1,1) : "Eright_wall" },
		 "persp_up_wall": {Vector2i(0, -1) : "wall", Vector2i(1,-1) : "Ewall"}}],
	1: [{"main": dicWall["normal"],
		 "persp_down": "down_wall",
		 "persp_left": { Vector2i(-1,0) : "full", Vector2i(-1,1) : "Eleft" },
		 "persp_right_wall": { Vector2i(1,0) : "full_wall", Vector2i(1,1) : "Eright_wall" },
		 "persp_up_wall": {Vector2i(1,-1) : "Ewall"}}],
	2: [{"main": dicWall["normal"],
		 "persp_down": "down_wall",
		 "persp_left": { Vector2i(-1,0) : "mini", Vector2i(-1,1) : "Eleft"},
		 "persp_up_wall": {Vector2i(0, -1) : "wall"}}],
	3: [{"main": dicWall["normal"],
		 "persp_down": "down_wall",
		 "persp_left": { Vector2i(-1,0) : "full", Vector2i(-1,1) : "Eleft" }}],
	4: [{"main" : dicWall["full"],
		 "persp_left": { Vector2i(-1,0) : "mini" },
		 "persp_right_wall": "mini_wall",
		 "persp_up_wall": {Vector2i(0, -1) : "wall", Vector2i(1,-1) : "Ewall"}}],
	5: [{"main" : dicWall["full"],
		 "persp_left": { Vector2i(-1,0) : "full" },
		 "persp_right_wall": "full_wall",
		 "persp_up_wall": {Vector2i(1,-1) : "Ewall"}}],
	6: [{"main" : dicWall["full"],
		 "persp_left": "mini",
		 "persp_up_wall": {Vector2i(0, -1) : "wall"}}],
	7: [{"main" : dicWall["full"],
		 "persp_left": { Vector2i(-1,0) : "full"}}],
	8: [{"main": dicWall["normal"],
		 "persp_down": "down_wall",
		 "persp_right_wall": { Vector2i(1,0) : "mini_wall", Vector2i(1,1) : "Eright_wall" },
		 "persp_up_wall": {Vector2i(0, -1) : "wall", Vector2i(1,-1) : "Ewall"}}],
	9: [{"main": dicWall["normal"],
		 "persp_down": "down_wall",
		 "persp_right_wall": { Vector2i(1,0) : "full_wall", Vector2i(1,1) : "Eright_wall" },
		 "persp_up_wall": {Vector2i(1,-1) : "Ewall"}}],
	10: [{"main": dicWall["normal"],
		  "persp_down": "down_wall",
		  "persp_up_wall": {Vector2i(0, -1) : "wall"}}],
	11: [{"main": dicWall["normal"],
		 "persp_down": "down_wall"}],
	12: [{"main" : dicWall["full"],
		  "persp_right_wall": "mini_wall",
		  "persp_up_wall": {Vector2i(0, -1) : "wall", Vector2i(1,-1) : "Ewall"}}],
	13: [{"main" : dicWall["full"],
		 "persp_right_wall": "full_wall",
		 "persp_up_wall": {Vector2i(1,-1) : "Ewall"}}],
	14: [{"main" : dicWall["full"],
		 "persp_up_wall": {Vector2i(0, -1) : "wall"}}],
	15: [{"main" : dicWall["full"]}]
}

const wall_grass_exceptions: Dictionary = {
	1: {"persp_right_wall": {Vector2i(1,0) : "full_wall", Vector2i(1,1) : "Eright_wall"},
		"persp_up_wall" : {Vector2i(0, -1) : "wall", Vector2i(1,-1) : "Ewall"},
		"persp_left" : { Vector2i(-1,0) : "full", Vector2i(-1,1) : "Eleft" },},
	2: {"persp_right_wall": {Vector2i(1,0) : "side_wall", Vector2i(1,1) : "Eright_wall"},
		"persp_up_wall" : {Vector2i(0, -1) : "wall", Vector2i(1,-1) : "Ewall", Vector2i(1,0) : "side_wall"},
		"forbid_Eright_wall" : true},
	3: {"persp_right_wall": {Vector2i(1,0) : "side_wall", Vector2i(1,1) : "Eright_wall"},
		"persp_up_wall" : {Vector2i(0, -1) : "wall", Vector2i(1,-1) : "Ewall", Vector2i(1,0) : "side_wall"},
		"persp_left" : { Vector2i(-1,0) : "full", Vector2i(-1,1) : "Eleft" },
		"forbid_Eright_wall" : true}
	}

func _ready() -> void:
	var btn_herbe = $UI_Layer/PanelContainer/HBoxContainer/Btn_Herbe
	var btn_mur = $UI_Layer/PanelContainer/HBoxContainer/Btn_Mur
	var btn_gomme = $UI_Layer/PanelContainer/HBoxContainer/Btn_Gomme
	var brush_group = ButtonGroup.new()
	btn_herbe.button_group = brush_group
	btn_mur.button_group = brush_group
	btn_gomme.button_group = brush_group
	btn_herbe.pressed.connect(func(): current_brush = Brush.GRASS)
	btn_mur.pressed.connect(func(): current_brush = Brush.WALL)
	btn_gomme.pressed.connect(func(): current_brush = Brush.ERASER)
	btn_herbe.button_pressed = true

func _process(_delta: float) -> void:
	var center_pixel_pos = camera.global_position
	var center_grid_pos = layer_floor.local_to_map(center_pixel_pos)
	lbl_coords.text = "X: %d, Y: %d" % [center_grid_pos.x, center_grid_pos.y]

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
		Brush.GRASS:
			var has_grass = layer_floor.get_cell_source_id(grid_pos) == GRASS_SOURCE_ID
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
					layer_floor.set_cell(grid_pos, GRASS_SOURCE_ID, Vector2i(0,0))
					layer_wall.set_cell(grid_pos, -1)
					update_smart_area(grid_pos)
			else:
				if is_repainting_theme:
					if has_grass and cell_themes.get(grid_pos, "_light") != current_target_theme:
						cell_themes[grid_pos] = current_target_theme
						update_smart_area(grid_pos)
				else:
					if not has_grass:
						cell_themes[grid_pos] = "_light"
						layer_floor.set_cell(grid_pos, GRASS_SOURCE_ID, Vector2i(0,0))
						layer_wall.set_cell(grid_pos, -1)
						update_smart_area(grid_pos)
		Brush.WALL:
			layer_wall.set_cell(grid_pos, WALL_SOURCE_ID, Vector2i(0, 0))
			layer_floor.set_cell(grid_pos, -1)
			cell_themes.erase(grid_pos)
			update_smart_area(grid_pos)
		Brush.ERASER:
			erase_all_layers(grid_pos)

func erase_all_layers(specific_pos = null) -> void:
	var grid_pos = specific_pos if specific_pos != null else layer_wall.local_to_map(get_global_mouse_position())
	cell_themes.erase(grid_pos)
	layer_floor.set_cell(grid_pos, -1)
	layer_wall.set_cell(grid_pos, -1)
	update_smart_area(grid_pos)

func update_smart_area(cell_pos: Vector2i) -> void:
	for x in range(-2, 3):
		for y in range(-2, 3):
			var target_cell = cell_pos + Vector2i(x, y)
			layer_persp_up.set_cell(target_cell, -1)
			layer_persp_up_wall.set_cell(target_cell, -1)
			layer_persp_down.set_cell(target_cell, -1)
			layer_persp_left.set_cell(target_cell, -1)
			layer_persp_right.set_cell(target_cell, -1)
			layer_persp_right_wall.set_cell(target_cell, -1)
	for x in range(-3, 4):
		for y in range(-3, 4):
			var target_cell = cell_pos + Vector2i(x, y)
			if layer_wall.get_cell_source_id(target_cell) == WALL_SOURCE_ID:
				apply_bitmask_to_single_cell(target_cell, layer_wall, wall_bitmask_repo, WALL_SOURCE_ID)
			if layer_floor.get_cell_source_id(target_cell) == GRASS_SOURCE_ID:
				apply_bitmask_to_single_cell(target_cell, layer_floor, grass_bitmask_repo, GRASS_SOURCE_ID)

func apply_bitmask_to_single_cell(cell_pos: Vector2i, layer: TileMapLayer, repo: Dictionary, source_id: int) -> void:
	var score : int = 0
	
	if source_id == WALL_SOURCE_ID:
		if is_tile_connected(layer, cell_pos + Vector2i.UP, source_id):    score += 1
		if is_tile_connected(layer, cell_pos + Vector2i.RIGHT, source_id): score += 2
		if is_tile_connected(layer, cell_pos + Vector2i.DOWN, source_id):  score += 4
		if is_tile_connected(layer, cell_pos + Vector2i.LEFT, source_id) or layer_floor.get_cell_source_id(cell_pos + Vector2i.LEFT) == GRASS_SOURCE_ID:  score += 8
	else:
		if is_tile_connected(layer, cell_pos + Vector2i.UP, source_id):    score += 1
		if is_tile_connected(layer, cell_pos + Vector2i.RIGHT, source_id): score += 2
		if is_tile_connected(layer, cell_pos + Vector2i.DOWN, source_id):  score += 4
		if is_tile_connected(layer, cell_pos + Vector2i.LEFT, source_id):  score += 8
		
	var theme = cell_themes.get(cell_pos, "_light")
	var main_theme_key = "dark" if theme == "_dark" else "light"
	
	if source_id == GRASS_SOURCE_ID:
		var main_atlas = get_tile_variation(cell_pos, dicFloor[main_theme_key], main_theme_key)
		apply_custom_cell(layer, cell_pos, source_id, main_atlas)
		
	if repo.has(score):
		var variations = repo[score]
		var pseudo_rand = posmod(hash(cell_pos), variations.size())
		var tile_data = variations[pseudo_rand].duplicate(true)
		if source_id == WALL_SOURCE_ID:
			var grass_score: int = 0
			if layer_floor.get_cell_source_id(cell_pos + Vector2i.UP) == GRASS_SOURCE_ID:    grass_score += 1
			if layer_floor.get_cell_source_id(cell_pos + Vector2i.RIGHT) == GRASS_SOURCE_ID: grass_score += 2
			if wall_grass_exceptions.has(grass_score):
				tile_data.merge(wall_grass_exceptions[grass_score], true)

		if source_id != GRASS_SOURCE_ID and tile_data.has("main") and tile_data["main"] != null:
			var data = tile_data["main"]
			if typeof(data) == TYPE_DICTIONARY:
				for offset in data:
					var final_atlas = get_tile_variation(cell_pos, data[offset], "main_" + str(offset))
					apply_custom_cell(layer, cell_pos + offset, source_id, final_atlas)
			else:
				var final_atlas = get_tile_variation(cell_pos, data, "main")
				apply_custom_cell(layer, cell_pos, source_id, final_atlas)

		if tile_data.has("persp_down") and tile_data["persp_down"] != null:
			var data = tile_data["persp_down"]
			var has_down_right = is_tile_connected(layer, cell_pos + Vector2i(1, 1), source_id)
			if has_down_right and typeof(data) == TYPE_DICTIONARY:
				var modified_data = data.duplicate()
				var keys_to_erase = []
				for offset in modified_data:
					if modified_data[offset] == "Eright_grass":
						keys_to_erase.append(offset)
				for k in keys_to_erase:
					modified_data.erase(k)
				data = modified_data
			if typeof(data) == TYPE_DICTIONARY:
				for offset in data:
					var final_atlas = dicDown.get(data[offset] + theme, dicDown.get(data[offset]))
					apply_custom_cell(layer_persp_down, cell_pos + offset, source_id, get_tile_variation(cell_pos, final_atlas, "persp_down_" + str(offset)))
			else:
				var final_atlas = dicDown.get(data + theme, dicDown.get(data))
				apply_custom_cell(layer_persp_down, cell_pos + Vector2i.DOWN, source_id, get_tile_variation(cell_pos, final_atlas, "persp_down"))

		if tile_data.has("persp_up") and tile_data["persp_up"] != null:
			var data = tile_data["persp_up"]
			var no_up = not is_tile_connected(layer, cell_pos + Vector2i.UP, source_id)
			var no_right = not is_tile_connected(layer, cell_pos + Vector2i.RIGHT, source_id)
			var no_up_right = not is_tile_connected(layer, cell_pos + Vector2i(1, -1), source_id)
			if no_up and no_right and no_up_right:
				if typeof(data) != TYPE_DICTIONARY:
					if data == "normal":
						data = { Vector2i(0, -1): "normal", Vector2i(1, -1): "E" }
			if typeof(data) == TYPE_DICTIONARY:
				for offset in data:
					var final_atlas = dicUp.get(data[offset] + theme, dicUp.get(data[offset]))
					apply_custom_cell(layer_persp_up, cell_pos + offset, source_id, get_tile_variation(cell_pos, final_atlas, "persp_up_" + str(offset)))
			else:
				var final_atlas = dicUp.get(data + theme, dicUp.get(data))
				apply_custom_cell(layer_persp_up, cell_pos + Vector2i.UP, source_id, get_tile_variation(cell_pos, final_atlas, "persp_up"))

		if tile_data.has("persp_left") and tile_data["persp_left"] != null:
			var data = tile_data["persp_left"]
			var forbid_eleft = tile_data.get("forbid_Eleft", false)
			if is_tile_connected(layer, cell_pos + Vector2i(-1, -1), source_id):
				if typeof(data) == TYPE_DICTIONARY:
					var modified_data = data.duplicate()
					for offset in modified_data:
						if modified_data[offset] == "full": modified_data[offset] = "mini"
					data = modified_data
				else:
					if data == "full": data = "mini"
			var has_down_left = is_tile_connected(layer, cell_pos + Vector2i(-1, 1), source_id)
			if (has_down_left or forbid_eleft) and typeof(data) == TYPE_DICTIONARY:
				var modified_data = data.duplicate()
				var keys_to_erase = []
				for offset in modified_data:
					if modified_data[offset] == "Eleft":
						keys_to_erase.append(offset)
				for k in keys_to_erase:
					modified_data.erase(k)
				data = modified_data
			if typeof(data) == TYPE_DICTIONARY:
				for offset in data:
					var final_atlas = dicLeft.get(data[offset] + theme, dicLeft.get(data[offset]))
					apply_custom_cell(layer_persp_left, cell_pos + offset, source_id, get_tile_variation(cell_pos, final_atlas, "persp_left_" + str(offset)))
			else:
				var final_atlas = dicLeft.get(data + theme, dicLeft.get(data))
				apply_custom_cell(layer_persp_left, cell_pos + Vector2i.LEFT, source_id, get_tile_variation(cell_pos, final_atlas, "persp_left"))

		if tile_data.has("persp_right") and tile_data["persp_right"] != null:
			var data = tile_data["persp_right"]
			var has_up_right = is_tile_connected(layer, cell_pos + Vector2i(1, -1), source_id)
			if has_up_right:
				if typeof(data) == TYPE_DICTIONARY:
					var modified_data = data.duplicate()
					for offset in modified_data:
						if modified_data[offset] == "full":
							modified_data[offset] = "mini"
						elif modified_data[offset] == "full_wall":
							modified_data[offset] = "mini_wall"
					data = modified_data
				else:
					if data == "full":
						data = "mini"
					elif data == "full_wall":
						data = "mini_wall"
			if typeof(data) == TYPE_DICTIONARY:
				for offset in data:
					var final_atlas = dicRight.get(data[offset] + theme, dicRight.get(data[offset]))
					apply_custom_cell(layer_persp_right, cell_pos + offset, source_id, get_tile_variation(cell_pos, final_atlas, "persp_right_" + str(offset)))
			else:
				var final_atlas = dicRight.get(data + theme, dicRight.get(data))
				apply_custom_cell(layer_persp_right, cell_pos + Vector2i.RIGHT, source_id, get_tile_variation(cell_pos, final_atlas, "persp_right"))

		if tile_data.has("persp_right_wall") and tile_data["persp_right_wall"] != null:
			var data = tile_data["persp_right_wall"]
			var forbid_eright_wall = tile_data.get("forbid_Eright_wall", false)
			var has_down_right = is_tile_connected(layer, cell_pos + Vector2i(1, 1), source_id)
			if (has_down_right or forbid_eright_wall) and typeof(data) == TYPE_DICTIONARY:
				var modified_data = data.duplicate()
				var keys_to_erase = []
				for offset in modified_data:
					if modified_data[offset] == "Eright_wall":
						keys_to_erase.append(offset)
				for k in keys_to_erase:
					modified_data.erase(k)
				data = modified_data
			if typeof(data) == TYPE_DICTIONARY:
				for offset in data:
					var final_atlas = dicRightWall.get(data[offset] + theme, dicRightWall.get(data[offset]))
					apply_custom_cell(layer_persp_right_wall, cell_pos + offset, source_id, get_tile_variation(cell_pos, final_atlas, "persp_right_wall_" + str(offset)))
			else:
				var final_atlas = dicRightWall.get(data + theme, dicRightWall.get(data))
				apply_custom_cell(layer_persp_right_wall, cell_pos + Vector2i.RIGHT, source_id, get_tile_variation(cell_pos, final_atlas, "persp_right_wall"))

		if tile_data.has("persp_up_wall") and tile_data["persp_up_wall"] != null:
			var data = tile_data["persp_up_wall"]
			if typeof(data) == TYPE_DICTIONARY:
				for offset in data:
					var final_atlas = dicUpWall.get(data[offset] + theme, dicUpWall.get(data[offset]))
					apply_custom_cell(layer_persp_up_wall, cell_pos + offset, source_id, get_tile_variation(cell_pos, final_atlas, "persp_up_wall_" + str(offset)))
			else:
				var final_atlas = dicUpWall.get(data + theme, dicUpWall.get(data))
				apply_custom_cell(layer_persp_up_wall, cell_pos + Vector2i.UP, source_id, get_tile_variation(cell_pos, final_atlas, "persp_up_wall"))

func get_tile_variation(cell_pos: Vector2i, data_source: Variant, layer_type: String) -> Variant:
	if typeof(data_source) != TYPE_ARRAY:
		return data_source
	var base_hash = hash(cell_pos)
	var seed_offset = hash(layer_type)
	var rand_idx = posmod(base_hash + seed_offset, data_source.size())
	return data_source[rand_idx]

func get_themed_data(dic: Dictionary, base_key: String, theme: String) -> Variant:
	var themed_key = base_key + "_" + theme
	if dic.has(themed_key):
		return dic[themed_key]
	return dic[base_key]

func apply_custom_cell(layer: TileMapLayer, target_pos: Vector2i, default_source_id: int, atlas_data: Variant) -> void:
	if atlas_data == null or typeof(atlas_data) == TYPE_STRING:
		return
	var final_source_id = default_source_id
	var final_coords = atlas_data
	if typeof(atlas_data) == TYPE_VECTOR3I:
		final_coords = Vector2i(atlas_data.x, atlas_data.y)
		final_source_id = atlas_data.z
	layer.set_cell(target_pos, final_source_id, final_coords)

func is_tile_connected(layer: TileMapLayer, pos: Vector2i, base_source_id: int) -> bool:
	if base_source_id == GRASS_SOURCE_ID:
		return layer_floor.get_cell_source_id(pos) == GRASS_SOURCE_ID or layer_wall.get_cell_source_id(pos) == WALL_SOURCE_ID
	return layer.get_cell_source_id(pos) == base_source_id
