extends Node2D

@onready var map_node: Node2D = $MAP
@onready var layer_floor: TileMapLayer = %tileMapLayer_floor
@onready var layer_wall: TileMapLayer = %tileMapLayer_wall
@onready var layer_persp_right: TileMapLayer = %TileMapLayer_perspective_right
@onready var layer_persp_down: TileMapLayer = %TileMapLayer_perspective_down
@onready var layer_persp_left: TileMapLayer = %TileMapLayer_perspective_left
@onready var layer_persp_up: TileMapLayer = %TileMapLayer_perspective_up

@onready var camera: Camera2D = $Camera2D
@onready var lbl_coords: Label = $UI_Layer/Coordonnees

var cell_themes: Dictionary = {}

enum Brush {GRASS, WALL, ICE, ERASER}
var current_brush: Brush = Brush.WALL
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

const dicLeft: Dictionary = {
	"full" : Vector2i(4,2),
	"mini" : Vector2i(4,3),
	"Eleft" : Vector2i(4,4)
}

const dicDown: Dictionary = {
	"down_grass" : [Vector2i(0,0),Vector2i(1,0),Vector2i(2,0),Vector2i(3,0)],
	"down_wall" : [Vector2i(0,1),Vector2i(1,1),Vector2i(2,1),Vector2i(3,1)],
	"Eright_grass" : Vector2i(0,4),
	"Eright_wall" : Vector2i(1,4)
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
	0: [{"main": Vector2i(0, 0), "persp_up": null, "persp_down": null, "persp_left": null, "persp_right": null}],
	1: [{"main": Vector2i(1, 0), "persp_up": null, "persp_down": null, "persp_left": null, "persp_right": null}],
	2: [{"main": Vector2i(2, 0), "persp_up": null, "persp_down": null, "persp_left": null, "persp_right": null}],
	3: [{"main": Vector2i(3, 0), "persp_up": null, "persp_down": null, "persp_left": null, "persp_right": null}],
	4: [{"main": Vector2i(0, 1), "persp_up": null, "persp_down": null, "persp_left": null, "persp_right": null}],
	5: [{"main": Vector2i(1, 1), "persp_up": null, "persp_down": null, "persp_left": null, "persp_right": null}],
	6: [{"main": Vector2i(2, 1), "persp_up": null, "persp_down": null, "persp_left": null, "persp_right": null}],
	7: [{"main": Vector2i(3, 1), "persp_up": null, "persp_down": null, "persp_left": null, "persp_right": null}],
	8: [{"main": Vector2i(0, 2), "persp_up": null, "persp_down": null, "persp_left": null, "persp_right": null}],
	9: [{"main": Vector2i(1, 2), "persp_up": null, "persp_down": null, "persp_left": null, "persp_right": null}],
	10: [{"main": Vector2i(2, 2), "persp_up": null, "persp_down": null, "persp_left": null, "persp_right": null}],
	11: [{"main": Vector2i(3, 2), "persp_down": Vector2i(3, 5), "persp_up": null, "persp_left": null, "persp_right": null}],
	12: [{"main": Vector2i(0, 3), "persp_up": null, "persp_down": null, "persp_left": null, "persp_right": null}],
	13: [{"main": Vector2i(1, 3), "persp_up": null, "persp_down": null, "persp_left": null, "persp_right": null}],
	14: [{"main": Vector2i(2, 3), "persp_up": null, "persp_down": null, "persp_left": null, "persp_right": null}],
	15: [{"main": Vector2i(3, 3), "persp_up": null, "persp_down": null, "persp_left": null, "persp_right": null}]
	}

func _ready() -> void:
	var btn_herbe = $UI_Layer/PanelContainer/HBoxContainer/Btn_Herbe
	var btn_mur = $UI_Layer/PanelContainer/HBoxContainer/Btn_Mur
	var btn_gomme = $UI_Layer/PanelContainer/HBoxContainer/Btn_Gomme
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
			if layer_floor.get_cell_source_id(grid_pos) == GRASS_SOURCE_ID:
				if is_just_clicked:
					if cell_themes.get(grid_pos, "light") == "light":
						cell_themes[grid_pos] = "dark"
					else:
						cell_themes[grid_pos] = "light"
					update_smart_area(grid_pos, layer_floor, grass_bitmask_repo, GRASS_SOURCE_ID, true)
			else:
				cell_themes[grid_pos] = "light"
				layer_floor.set_cell(grid_pos, GRASS_SOURCE_ID, Vector2i(0,0))
				update_smart_area(grid_pos, layer_floor, grass_bitmask_repo, GRASS_SOURCE_ID, true)
		Brush.WALL:
			layer_wall.set_cell(grid_pos, WALL_SOURCE_ID, Vector2i(0, 0))
			update_smart_area(grid_pos, layer_wall, wall_bitmask_repo, WALL_SOURCE_ID, true)
		Brush.ERASER:
			erase_all_layers(grid_pos)

func erase_all_layers(specific_pos = null) -> void:
	var grid_pos = specific_pos if specific_pos != null else layer_wall.local_to_map(get_global_mouse_position())
	cell_themes.erase(grid_pos)
	layer_floor.set_cell(grid_pos, -1)
	layer_wall.set_cell(grid_pos, -1)
	update_smart_area(grid_pos, layer_wall, wall_bitmask_repo, WALL_SOURCE_ID, true)
	update_smart_area(grid_pos, layer_floor, grass_bitmask_repo, GRASS_SOURCE_ID, true)

func update_smart_area(cell_pos: Vector2i, layer: TileMapLayer, repo: Dictionary, source_id: int, is_3d_wall: bool) -> void:
	for x in range(-2, 3):
		for y in range(-2, 3):
			var target_cell = cell_pos + Vector2i(x, y)
			layer_persp_up.set_cell(target_cell, -1)
			layer_persp_down.set_cell(target_cell, -1)
			layer_persp_left.set_cell(target_cell, -1)
			layer_persp_right.set_cell(target_cell, -1)
	for x in range(-3, 4):
		for y in range(-3, 4):
			var target_cell = cell_pos + Vector2i(x, y)
			if layer.get_cell_source_id(target_cell) == source_id:
				apply_bitmask_to_single_cell(target_cell, layer, repo, source_id, is_3d_wall)

func apply_bitmask_to_single_cell(cell_pos: Vector2i, layer: TileMapLayer, repo: Dictionary, source_id: int, is_3d_wall: bool) -> void:
	var score : int = 0
	if layer.get_cell_source_id(cell_pos + Vector2i.UP) == source_id:    score += 1
	if layer.get_cell_source_id(cell_pos + Vector2i.RIGHT) == source_id: score += 2
	if layer.get_cell_source_id(cell_pos + Vector2i.DOWN) == source_id:  score += 4
	if layer.get_cell_source_id(cell_pos + Vector2i.LEFT) == source_id:  score += 8
	var theme = cell_themes.get(cell_pos, "light") # On récupère la variable String de l'idée
	var main_atlas: Vector2i
	if source_id == GRASS_SOURCE_ID:
		main_atlas = get_tile_variation(cell_pos, dicFloor[theme], theme)
	elif source_id == WALL_SOURCE_ID:
		main_atlas = Vector2i(0,0)
	layer.set_cell(cell_pos, source_id, main_atlas)
	if repo.has(score):
		var variations = repo[score]
		var pseudo_rand = posmod(hash(cell_pos), variations.size())
		var tile_data = variations[pseudo_rand]
		
		if tile_data.has("persp_down") and tile_data["persp_down"] != null:
			var data = tile_data["persp_down"]
			if typeof(data) == TYPE_DICTIONARY:
				for offset in data:
					var final_atlas = get_themed_data(dicDown, data[offset], theme)
					layer_persp_down.set_cell(cell_pos + offset, source_id, get_tile_variation(cell_pos, final_atlas, "persp_down_" + str(offset)))
			else:
				var final_atlas = get_themed_data(dicDown, data, theme)
				layer_persp_down.set_cell(cell_pos + Vector2i.DOWN, source_id, get_tile_variation(cell_pos, final_atlas, "persp_down"))
		
		if tile_data.has("persp_up") and tile_data["persp_up"] != null:
			var data = tile_data["persp_up"]
			var no_up = layer.get_cell_source_id(cell_pos + Vector2i.UP) != source_id
			var no_right = layer.get_cell_source_id(cell_pos + Vector2i.RIGHT) != source_id
			var no_up_right = layer.get_cell_source_id(cell_pos + Vector2i(1, -1)) != source_id
			if no_up and no_right and no_up_right:
				if typeof(data) != TYPE_DICTIONARY:
					if data == "normal": # Regarde comme l'exception devient évidente !
						data = { Vector2i(0, -1): "normal", Vector2i(1, -1): "E" }
			if typeof(data) == TYPE_DICTIONARY:
				for offset in data:
					var final_atlas = get_themed_data(dicUp, data[offset], theme)
					layer_persp_up.set_cell(cell_pos + offset, source_id, get_tile_variation(cell_pos, final_atlas, "persp_up_" + str(offset)))
			else:
				var final_atlas = get_themed_data(dicUp, data, theme)
				layer_persp_up.set_cell(cell_pos + Vector2i.UP, source_id, get_tile_variation(cell_pos, final_atlas, "persp_up"))

		if tile_data.has("persp_left") and tile_data["persp_left"] != null:
			var data = tile_data["persp_left"]
			if layer.get_cell_source_id(cell_pos + Vector2i(-1, -1)) == source_id:
				if typeof(data) == TYPE_DICTIONARY:
					var modified_data = data.duplicate()
					for offset in modified_data:
						if modified_data[offset] == "full": modified_data[offset] = "mini"
					data = modified_data
				else:
					if data == "full": data = "mini"
			if typeof(data) == TYPE_DICTIONARY:
				for offset in data:
					var final_atlas = get_themed_data(dicLeft, data[offset], theme)
					layer_persp_left.set_cell(cell_pos + offset, source_id, get_tile_variation(cell_pos, final_atlas, "persp_left_" + str(offset)))
			else:
				var final_atlas = get_themed_data(dicLeft, data, theme)
				layer_persp_left.set_cell(cell_pos + Vector2i.LEFT, source_id, get_tile_variation(cell_pos, final_atlas, "persp_left"))
		
		if tile_data.has("persp_right") and tile_data["persp_right"] != null:
			var data = tile_data["persp_right"]
			if layer.get_cell_source_id(cell_pos + Vector2i(1, -1)) == source_id:
				if typeof(data) == TYPE_DICTIONARY:
					var modified_data = data.duplicate()
					for offset in modified_data:
						if modified_data[offset] == "full": modified_data[offset] = "mini"
					data = modified_data
				else:
					if data == "full": data = "mini"
			if typeof(data) == TYPE_DICTIONARY:
				for offset in data:
					var final_atlas = get_themed_data(dicRight, data[offset], theme)
					layer_persp_right.set_cell(cell_pos + offset, source_id, get_tile_variation(cell_pos, final_atlas, "persp_right_" + str(offset)))
			else:
				var final_atlas = get_themed_data(dicRight, data, theme)
				layer_persp_right.set_cell(cell_pos + Vector2i.RIGHT, source_id, get_tile_variation(cell_pos, final_atlas, "persp_right"))

func get_tile_variation(cell_pos: Vector2i, data_source: Variant, layer_type: String) -> Vector2i:
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
