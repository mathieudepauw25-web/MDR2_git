extends Node
class_name SaveLoadManager

const DOSSIER_NIVEAUX: String = "res://Larchet/LevelMaker/Level_temp/"

@onready var main = get_parent()

func sauvegarder_niveau() -> void:
	var player_grid_pos = main.layer_floor.local_to_map(main.sprite_player.global_position)
	var arrival_grid_pos = main.layer_floor.local_to_map(main.sprite_arrival.global_position)
	
	if main.current_level_id == -1 or main.current_file_path == "":
		_attribuer_nouveau_fichier()
		
	var json_data = {
		"global": {
			"level_id": main.current_level_id,
			"level_name": main.current_level_name,
			"grass_mode": main.grass_mode,
			"player_pos": [player_grid_pos.x, player_grid_pos.y],
			"arrival_pos": [arrival_grid_pos.x, arrival_grid_pos.y],
			"Tile_skin": main.current_skin_name
		},
		"cellules": {},
		"Interactives": {}
	}
	
	if main.grass_mode == 3 and main.pattern_window != null:
		var dark_cells = []
		for p in main.pattern_window.custom_pattern:
			if main.pattern_window.custom_pattern[p] == "_dark":
				dark_cells.append([p.x, p.y])
		json_data["grass_modele"] = {
			"taille": [main.pattern_window.pattern_size.x, main.pattern_window.pattern_size.y],
			"is_dark": dark_cells
		}
		
	var herbe_list = []
	var mur_list = []
	var ice_list = []
	var trans_list = []
	var bridge_list = []
	var fragreen_list = []
	var frawood_list = []
	var hidden_list = []
	
	var used_floor = main.layer_floor.get_used_cells()
	for pos in used_floor:
		if main.layer_floor.get_cell_source_id(pos) == TileSkinData.GRASS_SOURCE_ID:
			var theme = main.cell_themes.get(pos, "_light")
			match theme:
				"_dark": herbe_list.append([pos.x, pos.y, true])
				"_light": herbe_list.append([pos.x, pos.y])
				"_trans": trans_list.append([pos.x, pos.y])
				"_bridge_v": bridge_list.append([pos.x, pos.y, true])
				"_bridge_h": bridge_list.append([pos.x, pos.y])
				
	for pos in main.spawned_fragiles.keys():
		var theme = main.cell_themes.get(pos, "_fragreen")
		if theme == "_frawood":
			frawood_list.append([pos.x, pos.y])
		else:
			fragreen_list.append([pos.x, pos.y])
			
	for pos in main.spawned_hiddens.keys():
		hidden_list.append([pos.x, pos.y])
		
	var used_wall = main.layer_wall.get_used_cells()
	for pos in used_wall:
		if main.layer_wall.get_cell_source_id(pos) == TileSkinData.WALL_SOURCE_ID:
			mur_list.append([pos.x, pos.y])
			
	var used_ice = main.layer_ice.get_used_cells()
	for pos in used_ice:
		if main.layer_ice.get_cell_source_id(pos) == TileSkinData.ICE_SOURCE_ID:
			ice_list.append([pos.x, pos.y])
			
	var cellules = json_data["cellules"]
	if herbe_list.size() > 0: cellules["herbe"] = herbe_list
	if mur_list.size() > 0: cellules["mur"] = mur_list
	if ice_list.size() > 0: cellules["ice"] = ice_list
	if trans_list.size() > 0: cellules["transparent"] = trans_list
	if bridge_list.size() > 0: cellules["bridge"] = bridge_list
	if fragreen_list.size() > 0: cellules["fragreen"] = fragreen_list
	if frawood_list.size() > 0: cellules["frawood"] = frawood_list
	if hidden_list.size() > 0: cellules["hidden"] = hidden_list
	
	var platforms_list = []
	for plat in main.spawned_platforms.values():
		if is_instance_valid(plat):
			var p_area = plat.get_node("New_Platform")
			var path_coords = []
			for cell in p_area.way:
				path_coords.append([cell.x, cell.y])
			if p_area.is_looping and p_area.way.size() > 0:
				var first = p_area.way[0]
				path_coords.append([first.x, first.y])
			platforms_list.append({
				"path": path_coords,
				"start": p_area.start_index})
				
	if platforms_list.size() > 0:
		json_data["Interactives"]["Platforms"] = platforms_list
		
	JSONGestionnaire.sauvegarder_map(main.current_file_path, json_data)

func charger_editeur_depuis_json(chemin_json: String) -> void:
	main.current_file_path = chemin_json
	var map_data = JSONGestionnaire.charger_map(chemin_json)
	if not map_data.is_empty():
		generer_editeur_depuis_data(map_data)

func effacer_tout_lediteur() -> void:
	main._stop_configuring_interactive()
	main.cell_themes.clear()
	main.spawned_fragiles.clear()
	main.spawned_hiddens.clear()
	main.spawned_platforms.clear()
	
	if main.node_platforms != null:
		for enfant in main.node_platforms.get_children():
			enfant.free()
			
	for door in get_tree().get_nodes_in_group("Doors"):
		door.queue_free()
		
	var tous_les_layers: Array[TileMapLayer] = [
		main.layer_floor, main.layer_wall, main.layer_ice,
		main.layer_persp_right, main.layer_persp_right_wall, main.layer_persp_Eright_wall,
		main.layer_persp_right_ice, main.layer_persp_up, main.layer_persp_up_wall,
		main.layer_persp_up_ice, main.layer_persp_Wright, main.layer_persp_Wdown,
		main.layer_persp_Wleft, main.layer_fragile, main.layer_hidden
	]
	for calque in tous_les_layers:
		if calque != null:
			calque.clear()
			for enfant in calque.get_children():
				enfant.free()

func generer_editeur_depuis_data(map_data: Dictionary) -> void:
	effacer_tout_lediteur()
	var glob = map_data.get("global", {})
	main.current_level_id = int(glob.get("level_id", 1))
	main.current_level_name = str(glob.get("level_name", "Niveau " + str(main.current_level_id)))
	main.grass_mode = int(glob.get("grass_mode", 1))
	
	if main.ui_layer != null and main.ui_layer.has_method("sync_grass_mode"):
		main.ui_layer.sync_grass_mode(main.grass_mode)
		
	main.current_skin_name = str(glob.get("Tile_skin", "Normal"))
	
	var p_pos = glob.get("player_pos", [0, 0])
	var player_grid_pos = Vector2i(int(p_pos[0]), int(p_pos[1]))
	var a_pos = glob.get("arrival_pos", [4, 0])
	var arrival_grid_pos = Vector2i(int(a_pos[0]), int(a_pos[1]))
	
	if main.grass_mode == 3 and map_data.has("grass_modele") and main.pattern_window != null:
		var g_mod = map_data["grass_modele"]
		var t = g_mod.get("taille", [1, 1])
		main.pattern_window.pattern_size = Vector2i(int(t[0]), int(t[1]))
		main.pattern_window.custom_pattern.clear()
		for d in g_mod.get("is_dark", []):
			main.pattern_window.custom_pattern[Vector2i(int(d[0]), int(d[1]))] = "_dark"
			
	var cellules = map_data.get("cellules", {})
	for item in cellules.get("herbe", []):
		var pos = Vector2i(int(item[0]), int(item[1]))
		var is_dark = item[2] if item.size() > 2 else false
		main.cell_themes[pos] = "_dark" if is_dark else "_light"
		main.layer_floor.set_cell(pos, TileSkinData.GRASS_SOURCE_ID, Vector2i(0, 0))
		
	for item in cellules.get("mur", []):
		var pos = Vector2i(int(item[0]), int(item[1]))
		main.layer_wall.set_cell(pos, TileSkinData.WALL_SOURCE_ID, Vector2i(0, 0))
		
	for item in cellules.get("ice", []):
		var pos = Vector2i(int(item[0]), int(item[1]))
		main.layer_ice.set_cell(pos, TileSkinData.ICE_SOURCE_ID, Vector2i(0, 0))
		main.layer_floor.set_cell(pos, TileSkinData.GRASS_SOURCE_ID, Vector2i(0, 0))
		main.cell_themes[pos] = "_light"
		
	for item in cellules.get("transparent", []):
		var pos = Vector2i(int(item[0]), int(item[1]))
		main.cell_themes[pos] = "_trans"
		main.layer_floor.set_cell(pos, TileSkinData.GRASS_SOURCE_ID, Vector2i(0, 0))
		
	for item in cellules.get("bridge", []):
		var pos = Vector2i(int(item[0]), int(item[1]))
		var is_vertical = item[2] if item.size() > 2 else false
		main.cell_themes[pos] = "_bridge_v" if is_vertical else "_bridge_h"
		main.layer_floor.set_cell(pos, TileSkinData.GRASS_SOURCE_ID, Vector2i(0, 0))
		
	for item in cellules.get("fragreen", []):
		var pos = Vector2i(int(item[0]), int(item[1]))
		main._spawn_fragile(pos, "_fragreen")
		
	for item in cellules.get("frawood", []):
		var pos = Vector2i(int(item[0]), int(item[1]))
		main._spawn_fragile(pos, "_frawood")
		
	for item in cellules.get("hidden", []):
		var pos = Vector2i(int(item[0]), int(item[1]))
		main._spawn_hidden(pos, "_hidden")
		
	var interactives = map_data.get("Interactives", {})
	for plat_data in interactives.get("Platforms", []):
		var plat_path = []
		var start_idx = 0
		if typeof(plat_data) == TYPE_ARRAY:
			plat_path = plat_data
		elif typeof(plat_data) == TYPE_DICTIONARY:
			plat_path = plat_data.get("path", [])
			start_idx = int(plat_data.get("start", 0))
			
		if plat_path.size() > 0:
			var start_pos = Vector2i(int(plat_path[0][0]), int(plat_path[0][1]))
			var plat_way_inst = main.PLATFORM_SCENE.instantiate()
			plat_way_inst.position = Vector2.ZERO 
			var platform_area = plat_way_inst.get_node("New_Platform")
			platform_area.position = main.layer_floor.map_to_local(start_pos)
			main.node_platforms.add_child(plat_way_inst) 
			main.spawned_platforms[start_pos] = plat_way_inst
			
			var restored_way: Array[Vector2i] = []
			for coord in plat_path:
				restored_way.append(Vector2i(int(coord[0]), int(coord[1])))
				
			platform_area.start_index = start_idx
			platform_area.set_way(restored_way)
			platform_area.reset_to_editor()
			
	main.get_node("TileManager").rafraichir_autotiling_global()
	main.sprite_player.global_position = main.layer_floor.map_to_local(player_grid_pos) + Vector2(0, -2)
	main.sprite_arrival.global_position = main.layer_floor.map_to_local(arrival_grid_pos) + Vector2(0, -2)

func _generer_nouvel_id() -> int:
	var dir = DirAccess.open(DOSSIER_NIVEAUX)
	if dir == null:
		return 1
	var id_max: int = 0
	dir.list_dir_begin()
	var fichier_nom = dir.get_next()
	while fichier_nom != "":
		if not dir.current_is_dir() and fichier_nom.ends_with(".json"):
			var chemin_complet = DOSSIER_NIVEAUX + "/" + fichier_nom
			var map_data = JSONGestionnaire.charger_map(chemin_complet)
			if not map_data.is_empty() and map_data.has("global"):
				var id_lu = int(map_data["global"].get("level_id", 0))
				if id_lu > id_max:
					id_max = id_lu
		fichier_nom = dir.get_next()
	dir.list_dir_end()
	return id_max + 1

func _attribuer_nouveau_fichier() -> void:
	var nouvel_id: int = _generer_nouvel_id()
	var chemin_test: String = DOSSIER_NIVEAUX + "niveau_" + str(nouvel_id) + ".json"
	while FileAccess.file_exists(chemin_test):
		nouvel_id += 1
		chemin_test = DOSSIER_NIVEAUX + "niveau_" + str(nouvel_id) + ".json"
	main.current_level_id = nouvel_id
	main.current_level_name = "Niveau " + str(main.current_level_id)
	main.current_file_path = chemin_test
