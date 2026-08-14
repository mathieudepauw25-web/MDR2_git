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
		"Interactives": {},
		"Signals": {}
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
	var deco_list = []
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
	if main.layer_deco != null:
		var used_deco = main.layer_deco.get_used_cells()
		var deco_dict = main.get_node("TileManager").get_skin_element("", "deco")
		var cat_names = ["flower", "rock", "plant", "arrow"]
		for pos in used_deco:
			var atlas_coords = main.layer_deco.get_cell_atlas_coords(pos)
			var found_cat_idx = -1
			var found_sub_idx = -1
			if typeof(deco_dict) == TYPE_DICTIONARY:
				for i in range(cat_names.size()):
					var c_name = cat_names[i]
					if c_name == "arrow":
						if deco_dict.has("arrow"):
							for sub in ["arrow_light", "arrow_dark"]:
								if deco_dict["arrow"].has(sub):
									var arr = deco_dict["arrow"][sub]
									for j in range(arr.size()):
										if arr[j].x == atlas_coords.x and arr[j].y == atlas_coords.y:
											found_cat_idx = i
											found_sub_idx = j
											break
					else:
						if deco_dict.has(c_name):
							var arr = deco_dict[c_name]
							for j in range(arr.size()):
								if arr[j].x == atlas_coords.x and arr[j].y == atlas_coords.y:
									found_cat_idx = i
									found_sub_idx = j
									break
					if found_cat_idx != -1: break
			if found_cat_idx != -1:
				deco_list.append([[pos.x, pos.y], [found_cat_idx, found_sub_idx]])
	var cellules = json_data["cellules"]
	if herbe_list.size() > 0: cellules["herbe"] = herbe_list
	if mur_list.size() > 0: cellules["mur"] = mur_list
	if ice_list.size() > 0: cellules["ice"] = ice_list
	if trans_list.size() > 0: cellules["transparent"] = trans_list
	if bridge_list.size() > 0: cellules["bridge"] = bridge_list
	if fragreen_list.size() > 0: cellules["fragreen"] = fragreen_list
	if frawood_list.size() > 0: cellules["frawood"] = frawood_list
	if hidden_list.size() > 0: cellules["hidden"] = hidden_list
	if deco_list.size() > 0: cellules["deco"] = deco_list 
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
	var doors_list = []
	for door in get_tree().get_nodes_in_group("Doors"):
		var door_data_list = []
		for coord in door.debug_keys_coords:
			door_data_list.append([int(coord.x), int(coord.y)])
		var door_pos = main.layer_floor.local_to_map(door.global_position)
		door_data_list.append([int(door_pos.x), int(door_pos.y)])
		doors_list.append(door_data_list)
	if doors_list.size() > 0:
		json_data["Interactives"]["Doors"] = doors_list
	var portals_list = []
	for portal in get_tree().get_nodes_in_group("Portals"):
		var p_pos = main.layer_floor.local_to_map(portal.global_position)
		var t_pos = portal.target_portal_pos
		if is_instance_valid(portal.get("target_portal_node")):
			t_pos = main.layer_floor.local_to_map(portal.target_portal_node.global_position)
		elif is_instance_valid(portal.get("target_portal")):
			t_pos = main.layer_floor.local_to_map(portal.target_portal.global_position)
		portals_list.append([[p_pos.x, p_pos.y], [t_pos.x, t_pos.y]])
	if portals_list.size() > 0:
		json_data["Interactives"]["Portals"] = portals_list
	if main.has_method("build_signals_array"):
		var signals_data = main.build_signals_array()
		if signals_data.size() > 0:
			json_data["Signals"]["DoorPlatform"] = signals_data
	JSONGestionnaire.sauvegarder_map(main.current_file_path, json_data)
	var backup_dir = "user://Levels/"
	if not DirAccess.dir_exists_absolute(backup_dir):
		DirAccess.make_dir_recursive_absolute(backup_dir)
	var nom_fichier = main.current_file_path.get_file()
	JSONGestionnaire.sauvegarder_map(backup_dir + nom_fichier, json_data)

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
	for item in cellules.get("deco", []):
		var pos = Vector2i(int(item[0][0]), int(item[0][1]))
		var cat_idx = int(item[1][0])
		var sub_idx = int(item[1][1])
		var old_cat = main.current_deco_category
		var old_idx = main.current_deco_index
		var cat_names = ["flower", "rock", "plant", "arrow"]
		if cat_idx >= 0 and cat_idx < cat_names.size():
			main.current_deco_category = cat_names[cat_idx]
			main.current_deco_index = sub_idx
			main.get_node("TileManager")._apply_deco(pos)
		main.current_deco_category = old_cat
		main.current_deco_index = old_idx
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
	var doors_data = interactives.get("Doors", [])
	for door_list in doors_data:
		if typeof(door_list) == TYPE_ARRAY and door_list.size() > 0:
			var d_pos = door_list.back()
			var door_grid_pos = Vector2i(int(d_pos[0]), int(d_pos[1]))
			var keys_coords: Array[Vector2] = []
			for i in range(door_list.size() - 1):
				var k_pos = door_list[i]
				keys_coords.append(Vector2(int(k_pos[0]), int(k_pos[1])))
			var new_door = main.DOOR_SCENE.instantiate()
			if not keys_coords.is_empty():
				new_door.debug_keys_coords = keys_coords
			main.map_node.add_child(new_door)
			new_door.global_position = main.layer_floor.map_to_local(door_grid_pos)
	var portals_data = interactives.get("Portals", [])
	var spawned_portals_dict = {}
	for p_data in portals_data:
		if p_data.size() == 2:
			var p_pos1 = Vector2i(int(p_data[0][0]), int(p_data[0][1]))
			var new_portal = main.PORTAL_SCENE.instantiate()
			main.map_node.add_child(new_portal)
			new_portal.global_position = main.layer_floor.map_to_local(p_pos1)
			spawned_portals_dict[p_pos1] = new_portal
	for p_data in portals_data:
		if p_data.size() == 2:
			var p_pos2 = Vector2i(int(p_data[0][0]), int(p_data[0][1]))
			var t_pos = Vector2i(int(p_data[1][0]), int(p_data[1][1]))
			if spawned_portals_dict.has(p_pos2) and spawned_portals_dict.has(t_pos):
				var portal = spawned_portals_dict[p_pos2]
				var target = spawned_portals_dict[t_pos]
				portal.target_portal_pos = t_pos
				portal.target_portal_node = target
				portal.target_portal = target
	var signals = map_data.get("Signals", {})
	if signals.has("DoorPlatform") and main.has_method("restore_signals_from_array"):
		main.call_deferred("restore_signals_from_array", signals["DoorPlatform"])
	main.get_node("TileManager").rafraichir_autotiling_global()
	main.sprite_player.global_position = main.layer_floor.map_to_local(player_grid_pos) + Vector2(0, -1.5)
	main.sprite_arrival.global_position = main.layer_floor.map_to_local(arrival_grid_pos)

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
	for portal in get_tree().get_nodes_in_group("Portals"):
		portal.queue_free()
	var tous_les_layers: Array[TileMapLayer] = [
		main.layer_floor, main.layer_wall, main.layer_ice,
		main.layer_persp_right, main.layer_persp_right_wall, main.layer_persp_Eright_wall,
		main.layer_persp_right_ice, main.layer_persp_up, main.layer_persp_up_wall,
		main.layer_persp_up_ice, main.layer_persp_Wright, main.layer_persp_Wdown,
		main.layer_persp_Wleft, main.layer_fragile, main.layer_hidden, main.layer_deco
	]
	for calque in tous_les_layers:
		if calque != null:
			calque.clear()
			for enfant in calque.get_children():
				enfant.free()

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
