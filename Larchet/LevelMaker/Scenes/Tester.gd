extends Node2D

@onready var map_node: Node2D = $MAP_global
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
@onready var layer_fragile: TileMapLayer = %tileMapLayer_fragile
@onready var layer_hidden: TileMapLayer = %tileMapLayer_hidden

const PLAYER_SCENE = preload("res://Player/Player.tscn")
const FRAGILE_SCENE = preload("res://Fragile/Fragile.tscn")
const HIDDEN_SCENE = preload("res://Hidden/Hidden.tscn")

var player: Node2D = null
var spawned_fragiles: Dictionary = {}
var spawned_hiddens: Dictionary = {}

var cell_themes: Dictionary = {}
var grass_mode: int = 1
var current_skin_name: String = "Normal"
var editeur_parent: Node2D = null

var custom_pattern: Dictionary = {}
var pattern_size: Vector2i = Vector2i(1, 1)

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

func _ready() -> void:
	_init_active_layers()
	effacer_tous_les_layers()
	EVENTS.connect("create_floor_tile", _on_create_floor_tile)
	EVENTS.connect("erase_floor_tile", _on_erase_floor_tile)

func _init_active_layers() -> void:
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

func charger_et_generer(chemin_json: String) -> void:
	var map_data = JSONGestionnaire.charger_map(chemin_json)
	if not map_data.is_empty():
		generer_niveau(map_data)

func generer_niveau(map_data: Dictionary) -> void:
	_nettoyer_niveau()
	_init_active_layers()
	var glob = map_data.get("global", {})
	grass_mode = int(glob.get("grass_mode", 1))
	current_skin_name = str(glob.get("Tile_skin", "Normal"))
	var p_pos = glob.get("player_pos", [0, 0])
	var player_grid_pos = Vector2i(int(p_pos[0]), int(p_pos[1]))
	if grass_mode == 3 and map_data.has("grass_modele"):
		var g_mod = map_data["grass_modele"]
		var t = g_mod.get("taille", [1, 1])
		pattern_size = Vector2i(int(t[0]), int(t[1]))
		custom_pattern.clear()
		for d in g_mod.get("is_dark", []):
			custom_pattern[Vector2i(int(d[0]), int(d[1]))] = "_dark"
	var cellules = map_data.get("cellules", {})
	for item in cellules.get("herbe", []):
		var pos = Vector2i(int(item[0]), int(item[1]))
		var is_dark = item[2] if item.size() > 2 else false
		cell_themes[pos] = "_dark" if is_dark else "_light"
		layer_floor.set_cell(pos, TileSkinData.GRASS_SOURCE_ID, Vector2i(0, 0))
	for item in cellules.get("mur", []):
		var pos = Vector2i(int(item[0]), int(item[1]))
		layer_wall.set_cell(pos, TileSkinData.WALL_SOURCE_ID, Vector2i(0, 0))
	for item in cellules.get("ice", []):
		var pos = Vector2i(int(item[0]), int(item[1]))
		layer_ice.set_cell(pos, TileSkinData.ICE_SOURCE_ID, Vector2i(0, 0))
		layer_floor.set_cell(pos, TileSkinData.GRASS_SOURCE_ID, Vector2i(0, 0))
		cell_themes[pos] = "_light"
	for item in cellules.get("transparent", []):
		var pos = Vector2i(int(item[0]), int(item[1]))
		cell_themes[pos] = "_trans"
		layer_floor.set_cell(pos, TileSkinData.GRASS_SOURCE_ID, Vector2i(0, 0))
	for item in cellules.get("bridge", []):
		var pos = Vector2i(int(item[0]), int(item[1]))
		var is_vertical = item[2] if item.size() > 2 else false
		cell_themes[pos] = "_bridge_v" if is_vertical else "_bridge_h"
		layer_floor.set_cell(pos, TileSkinData.GRASS_SOURCE_ID, Vector2i(0, 0))
	for item in cellules.get("fragreen", []):
		var pos = Vector2i(int(item[0]), int(item[1]))
		_spawn_fragile(pos, "_fragreen")
	for item in cellules.get("frawood", []):
		var pos = Vector2i(int(item[0]), int(item[1]))
		_spawn_fragile(pos, "_frawood")
	for item in cellules.get("hidden", []):
		var pos = Vector2i(int(item[0]), int(item[1]))
		_spawn_hidden(pos, "_hidden")
	rafraichir_autotiling_global()
	_spawn_player(player_grid_pos)

func rafraichir_autotiling_global() -> void:
	var toutes_les_cases: Dictionary = {}
	for pos in layer_wall.get_used_cells():
		toutes_les_cases[pos] = true
	for pos in layer_floor.get_used_cells():
		toutes_les_cases[pos] = true
	for pos in layer_ice.get_used_cells():
		toutes_les_cases[pos] = true
	var liste_triee: Array[Vector2i] = []
	for pos in toutes_les_cases.keys():
		liste_triee.append(pos)
	liste_triee.sort_custom(func(a: Vector2i, b: Vector2i) -> bool:
		if a.y == b.y:
			return a.x < b.x
		return a.y < b.y
	)
	for pos in liste_triee:
		if get_source_id(layer_wall, pos) == TileSkinData.WALL_SOURCE_ID:
			apply_bitmask_to_single_cell(pos, layer_wall, TileSkinData.wall_bitmask_repo, TileSkinData.WALL_SOURCE_ID)
		if get_source_id(layer_floor, pos) == TileSkinData.GRASS_SOURCE_ID:
			apply_bitmask_to_single_cell(pos, layer_floor, TileSkinData.grass_bitmask_repo, TileSkinData.GRASS_SOURCE_ID)
		if get_source_id(layer_ice, pos) == TileSkinData.ICE_SOURCE_ID:
			apply_bitmask_to_single_cell(pos, layer_ice, TileSkinData.grass_bitmask_repo, TileSkinData.ICE_SOURCE_ID)

func _nettoyer_niveau() -> void:
	cell_themes.clear()
	for fragile in spawned_fragiles.values():
		if is_instance_valid(fragile): fragile.queue_free()
	spawned_fragiles.clear()
	for h in spawned_hiddens.values():
		if is_instance_valid(h): h.queue_free()
	spawned_hiddens.clear()
	if is_instance_valid(player):
		player.queue_free()
		player = null
	var layers = [layer_floor, layer_wall, layer_ice, layer_persp_right, layer_persp_right_wall, 
				  layer_persp_Eright_wall, layer_persp_right_ice, layer_persp_up, layer_persp_up_wall, 
				  layer_persp_up_ice, layer_persp_Wright, layer_persp_Wdown, layer_persp_Wleft, 
				  layer_fragile, layer_hidden]
	for l in layers:
		if l != null: l.clear()

func _spawn_player(grid_pos: Vector2i) -> void:
	if PLAYER_SCENE == null: return
	player = PLAYER_SCENE.instantiate()
	player.position = layer_floor.map_to_local(grid_pos) + Vector2(0, -2)
	player.z_index = 5
	add_child(player)
	var player_camera = player.get_node_or_null("Camera2D")
	if player_camera != null:
		player_camera.make_current()

func _spawn_fragile(grid_pos: Vector2i, target_theme: String) -> void:
	cell_themes[grid_pos] = target_theme
	layer_floor.set_cell(grid_pos, TileSkinData.GRASS_SOURCE_ID, Vector2i(14, 0))
	if layer_fragile != null:
		var fragile = FRAGILE_SCENE.instantiate()
		fragile.position = layer_fragile.map_to_local(grid_pos)
		layer_fragile.add_child(fragile)
		spawned_fragiles[grid_pos] = fragile

func _spawn_hidden(grid_pos: Vector2i, target_theme: String) -> void:
	cell_themes[grid_pos] = target_theme
	layer_floor.set_cell(grid_pos, TileSkinData.GRASS_SOURCE_ID, Vector2i(14, 0))
	if layer_hidden != null:
		var hidden_inst = HIDDEN_SCENE.instantiate()
		hidden_inst.position = layer_hidden.map_to_local(grid_pos)
		layer_hidden.add_child(hidden_inst)
		spawned_hiddens[grid_pos] = hidden_inst

func apply_skin_to_fragile(fragile_node: Node2D) -> void:
	if layer_fragile == null: return
	var grid_pos = layer_fragile.local_to_map(fragile_node.position)
	var theme = cell_themes.get(grid_pos, "_fragreen")
	var skin_key = "fragile_wood" if theme == "_frawood" else "fragile_dark"
	var skin_data = get_skin_element("", skin_key, "")
	if skin_data == null: return
	var atlas_data = get_tile_variation(grid_pos, skin_data, skin_key)
	var final_coords: Vector2i
	var final_source_id: int = TileSkinData.GRASS_SOURCE_ID 
	if typeof(atlas_data) == TYPE_VECTOR3I:
		final_coords = Vector2i(atlas_data.x, atlas_data.y)
		final_source_id = atlas_data.z
	elif typeof(atlas_data) == TYPE_VECTOR2I:
		final_coords = atlas_data
	var atlas_source = layer_fragile.tile_set.get_source(final_source_id) as TileSetAtlasSource
	if atlas_source:
		var base_texture = atlas_source.texture
		if theme == "_frawood":
			fragile_node.set_skin(base_texture, final_coords, true)
		else:
			fragile_node.set_skin(base_texture, final_coords, false)

func apply_skin_to_hidden(hidden_node: Node2D) -> void:
	if layer_hidden == null: return
	var grid_pos = layer_hidden.local_to_map(hidden_node.position)
	var skin_key = "hidden"
	var skin_data = get_skin_element("", skin_key, "")
	if skin_data == null: return
	var atlas_data = get_tile_variation(grid_pos, skin_data, skin_key)
	var final_coords: Vector2i
	var final_source_id: int = TileSkinData.GRASS_SOURCE_ID
	if typeof(atlas_data) == TYPE_VECTOR3I:
		final_coords = Vector2i(atlas_data.x, atlas_data.y)
		final_source_id = atlas_data.z
	elif typeof(atlas_data) == TYPE_VECTOR2I:
		final_coords = atlas_data
	var atlas_source = layer_floor.tile_set.get_source(final_source_id) as TileSetAtlasSource
	if atlas_source:
		var base_texture = atlas_source.texture
		hidden_node.set_skin(base_texture, final_coords)

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

func is_grass_or_ice(pos: Vector2i) -> bool:
	var theme = cell_themes.get(pos)
	if theme == "_trans" or theme == "_bridge_v" or theme == "_bridge_h" or theme == "_frawood" or theme == "_fragreen" or theme == "_hidden":
		return false
	return get_source_id(layer_floor, pos) == TileSkinData.GRASS_SOURCE_ID

func get_grass_theme(cell_pos: Vector2i) -> String:
	var theme = cell_themes.get(cell_pos)
	if theme == "_trans" or theme == "_bridge_v" or theme == "_bridge_h" or theme == "_fragreen" or theme == "_frawood" or theme == "_hidden":
		return theme
	match grass_mode:
		1: return cell_themes.get(cell_pos, "_light")
		2: return "_light" if posmod(cell_pos.x + cell_pos.y, 2) == 0 else "_dark"
		3:
			if custom_pattern.is_empty(): return "_light"
			var px = posmod(cell_pos.x, pattern_size.x)
			var py = posmod(cell_pos.y, pattern_size.y)
			return custom_pattern.get(Vector2i(px, py), "_light")
	return "_light"

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
		return is_grass_or_ice(pos) or get_source_id(layer_wall, pos) == TileSkinData.WALL_SOURCE_ID
	return get_source_id(layer, pos) == base_source_id

func apply_bitmask_to_single_cell(cell_pos: Vector2i, layer: TileMapLayer, repo: Dictionary, source_id: int) -> void:
	if layer == null: return
	var theme = get_grass_theme(cell_pos)
	
	if source_id == TileSkinData.GRASS_SOURCE_ID:
		if theme == "_fragreen" or theme == "_frawood" or theme == "_hidden":
			apply_custom_cell(layer, cell_pos, source_id, Vector2i(14, 0))
			return
		elif theme == "_trans":
			var trans_atlas = get_tile_variation(cell_pos, get_skin_element("", "transparent"), "transparent")
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
		if is_tile_connected(layer, cell_pos + Vector2i.LEFT, source_id) or is_grass_or_ice(cell_pos + Vector2i.LEFT): score += 8
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

func definir_editeur_parent(editeur: Node2D) -> void:
	editeur_parent = editeur

func _on_bouton_retour_pressed() -> void:
	if is_instance_valid(editeur_parent) and editeur_parent.has_method("quitter_scene_test"):
		editeur_parent.quitter_scene_test()
	else:
		queue_free()

func _on_create_floor_tile(pos_globale: Vector2) -> void:
	var grid_pos = layer_floor.local_to_map(pos_globale)
	layer_floor.set_cell(grid_pos, TileSkinData.GRASS_SOURCE_ID, Vector2i(14, 0))

func _on_erase_floor_tile(pos_globale: Vector2) -> void:
	var grid_pos = layer_floor.local_to_map(pos_globale)
	layer_floor.set_cell(grid_pos, -1)

func effacer_tous_les_layers() -> void:
	cell_themes.clear()
	spawned_fragiles.clear()
	spawned_hiddens.clear()
	if is_instance_valid(player):
		player.queue_free()
		player = null
	var tous_les_layers: Array[TileMapLayer] = [
		layer_floor, layer_wall, layer_ice,
		layer_persp_right, layer_persp_right_wall, layer_persp_Eright_wall,
		layer_persp_right_ice, layer_persp_up, layer_persp_up_wall,
		layer_persp_up_ice, layer_persp_Wright, layer_persp_Wdown,
		layer_persp_Wleft, layer_fragile, layer_hidden]
	for calque in tous_les_layers:
		if calque != null:
			calque.clear()
			for enfant in calque.get_children():
				enfant.free()
