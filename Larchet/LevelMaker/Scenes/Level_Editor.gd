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
@onready var node_platforms: Node2D = %Platforms

@onready var camera: Camera2D = $Camera2D
@onready var ui_layer = $UI_Layer
@onready var pattern_window: Window = %PatternWindow

@onready var sprite_player = $Sprite_player
@onready var sprite_arrival = $Sprite_arrival

@onready var selection: Panel = %Selection

const PLAYER_SCENE = preload("res://Player/Player.tscn")
const ARRIVAL_SCENE = preload("res://Arrival/Arrival.tscn")
const FRAGILE_SCENE = preload("res://Fragile/Fragile.tscn")
const HIDDEN_SCENE = preload("res://Hidden/Hidden.tscn")
const SCENE_TEST = preload("res://Larchet/LevelMaker/Scenes/Level_Editor_Tester.tscn")
const PLATFORM_SCENE = preload("res://New_Platform/New_Platform.tscn")
const DOOR_SCENE = preload("res://New_Door/New_Door.tscn") 

var spawned_platforms: Dictionary = {}
var active_configured_platform: Node2D = null
var active_configured_door: New_Door = null
var active_configured_key: Keys = null

var current_level_id: int = -1
var current_level_name: String = ""
var current_file_path: String = ""
var instance_scene_test: Node2D = null
var player: Node2D = null
var arrival_instance: Node2D = null
var spawned_fragiles: Dictionary = {}
var spawned_hiddens: Dictionary = {}

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

var is_dragging_platform: bool = false
var dragged_platform: Area2D = null
var platform_drag_start_pos: Vector2 = Vector2.ZERO

var is_dragging_door: bool = false
var door_drag_start_pos: Vector2 = Vector2.ZERO
var is_dragging_key: bool = false
var key_drag_start_pos: Vector2 = Vector2.ZERO
var door_was_already_selected: bool = false
var lines_drawer: Node2D
var is_pressing_door: bool = false
var is_pressing_key: bool = false
var drag_start_mouse_pos: Vector2 = Vector2.ZERO
var temp_doors_save: Array = []

var grass_mode: int = 1
var current_brush: TileSkinData.Brush = TileSkinData.Brush.GRASS
var current_skin_name: String = "Normal"

var is_dragging_player: bool = false
var player_drag_start_pos: Vector2 = Vector2.ZERO

var is_dragging_arrival: bool = false
var arrival_drag_start_pos: Vector2 = Vector2.ZERO

var is_moving: bool = false

enum EditMode { FLOOR, INTERACTIVE }
enum InteractiveType { NONE, DOOR, PLATFORM, PORTAL }

var current_edit_mode: EditMode = EditMode.FLOOR
var current_interactive_type: InteractiveType = InteractiveType.NONE

func _ready() -> void:
	lines_drawer = Node2D.new()
	lines_drawer.z_index = 100
	add_child(lines_drawer)
	lines_drawer.draw.connect(_on_lines_drawer_draw)
	pattern_window.main_node = self
	pattern_window.hide()
	if ui_layer.has_signal("brush_selected"):
		ui_layer.brush_selected.connect(func(brush):
			current_brush = brush)
	if ui_layer.has_signal("grass_mode_toggled"):
		ui_layer.grass_mode_toggled.connect(func(mode):
			grass_mode = mode
			if grass_mode != 3: pattern_window.hide()
			$TileManager.refresh_all_grass())
	if ui_layer.has_signal("mode3_toggled"):
		ui_layer.mode3_toggled.connect(func():
			pattern_window.visible = not pattern_window.visible
			if pattern_window.visible:
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE))
	for x in range(-1, 2):
		for y in range(-1, 2):
			var grid_pos = Vector2i(x, y)
			cell_themes[grid_pos] = "_light"
			layer_floor.set_cell(grid_pos, TileSkinData.GRASS_SOURCE_ID, Vector2i(0,0))
			layer_wall.set_cell(grid_pos, -1)
			layer_ice.set_cell(grid_pos, -1)
			$TileManager.update_smart_area(grid_pos)
	var default_arrival_pos = Vector2i(4, 0)
	sprite_arrival.global_position = layer_floor.map_to_local(default_arrival_pos) + Vector2(0, -2)
	for x in range(-1, 2):
		for y in range(-1, 2):
			var grid_pos = default_arrival_pos + Vector2i(x, y)
			cell_themes[grid_pos] = "_light"
			layer_floor.set_cell(grid_pos, TileSkinData.GRASS_SOURCE_ID, Vector2i(0,0))
			layer_wall.set_cell(grid_pos, -1)
			layer_ice.set_cell(grid_pos, -1)
			$TileManager.update_smart_area(grid_pos)
	var player_area = sprite_player.get_node_or_null("Area2D")
	if player_area:
		player_area.input_event.connect(_on_player_area_input_event)
	var arrival_area = sprite_arrival.get_node_or_null("Area2D")
	if arrival_area:
		arrival_area.input_event.connect(_on_arrival_area_input_event)
	if ui_layer.has_signal("edit_mode_changed"):
		ui_layer.edit_mode_changed.connect(func(mode): 
			current_edit_mode = mode
			if mode == EditMode.FLOOR:
				_stop_configuring_interactive()
		)
	if ui_layer.has_signal("interactive_type_changed"):
		ui_layer.interactive_type_changed.connect(func(type): 
			current_interactive_type = type
			_stop_configuring_interactive())

func _process(_delta: float) -> void:
	queue_redraw()
	if lines_drawer:
		lines_drawer.queue_redraw()
	var center_pixel_pos = camera.global_position
	var center_grid_pos = layer_floor.local_to_map(center_pixel_pos)
	if ui_layer.has_method("update_coords"):
		ui_layer.update_coords(center_grid_pos.x, center_grid_pos.y)
	if player == null and instance_scene_test == null:
		_gerer_animations_cles(false)

# ==============================================================================
# --- TRACÉ DES LIGNES (DOOR / KEYS) ---
# ==============================================================================

func _on_lines_drawer_draw() -> void:
	if player != null or instance_scene_test != null: return
	if current_edit_mode != EditMode.INTERACTIVE or current_interactive_type != InteractiveType.DOOR: return
	for door in get_tree().get_nodes_in_group("Doors"):
		var keys_container = door.get_node_or_null("Keys")
		if keys_container:
			for key in keys_container.get_children():
				lines_drawer.draw_line(door.global_position, key.global_position, Color(1, 0.8, 0, 0.6), 2.0)

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

func _unhandled_input(event: InputEvent) -> void:
	if is_moving:
		return
	if event is InputEventMouseMotion or event is InputEventMouseButton:
		var is_left_clicking = Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
		var is_right_clicking = Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT)
		var is_just_clicked = false
		var is_right_just_clicked = false
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
				is_just_clicked = true
			elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
				is_right_just_clicked = true
		if is_left_clicking and not camera.is_panning:
			var mouse_pos = get_global_mouse_position()
			var grid_pos = layer_floor.local_to_map(mouse_pos)
			if current_edit_mode == EditMode.FLOOR:
				if has_node("TileManager"): $TileManager.paint_smart_tile(is_just_clicked)
			elif current_edit_mode == EditMode.INTERACTIVE:
				if has_node("InteractiveManager"): $InteractiveManager._handle_interactive_click(grid_pos, is_just_clicked)
		elif is_right_clicking and not camera.is_panning:
			var mouse_pos = get_global_mouse_position()
			var grid_pos = layer_floor.local_to_map(mouse_pos)
			if current_edit_mode == EditMode.FLOOR:
				if has_node("TileManager"): $TileManager.erase_all_layers()
			elif current_edit_mode == EditMode.INTERACTIVE and is_right_just_clicked:
				if has_node("InteractiveManager"): $InteractiveManager._handle_interactive_erase(grid_pos)
	if event is InputEventKey:
		if event.keycode == KEY_SPACE and not event.echo:
			$TileManager.refresh_all_grass()
		if event.is_action_pressed("ui_cancel"):
			queue_free()
			get_tree().change_scene_to_file("res://Larchet/Menus/LevelEditor/Menu_Level_Editor.tscn")

func _gerer_animations_cles(jouer: bool) -> void:
	for door in get_tree().get_nodes_in_group("Doors"):
		var keys_container = door.get_node_or_null("Keys")
		if keys_container:
			for key in keys_container.get_children():
				var anim_sprite = key.get_node_or_null("AnimatedSprite2D")
				if anim_sprite:
					if jouer: anim_sprite.play()
					else: anim_sprite.pause()
				var anim_player = key.get_node_or_null("AnimationPlayer")
				if anim_player:
					if jouer: anim_player.play()
					else: anim_player.pause()

func play_map():
	player = PLAYER_SCENE.instantiate()
	player.position = sprite_player.global_position
	player.z_index = 5
	add_child(player)
	sprite_player.visible = false
	sprite_arrival.visible = false 
	arrival_instance = ARRIVAL_SCENE.instantiate()
	arrival_instance.position = sprite_arrival.global_position
	add_child(arrival_instance)
	sprite_arrival.visible = false
	var arrival_grid_pos = layer_floor.local_to_map(sprite_arrival.global_position)
	if has_node("TileManager"): $TileManager.update_smart_area(arrival_grid_pos)
	var player_camera = player.get_node_or_null("Camera2D")
	if player_camera != null:
		player_camera.make_current()
	for hidden_block in spawned_hiddens.values():
		if is_instance_valid(hidden_block):
			hidden_block.sprite.scale = Vector2.ZERO
	temp_doors_save.clear()
	for door in get_tree().get_nodes_in_group("Doors"):
		var keys_rel: Array[Vector2] = []
		for coord in door.debug_keys_coords:
			keys_rel.append(Vector2(coord.x, coord.y))
		temp_doors_save.append({
			"pos": layer_floor.local_to_map(door.global_position),
			"keys": keys_rel
		})
	_gerer_animations_cles(true)

func back_to_editor():
	get_tree().call_group("UI_Arrival", "queue_free")
	if player: player.queue_free()
	if arrival_instance: arrival_instance.queue_free()
	camera.make_current()
	sprite_player.visible = true
	sprite_arrival.visible = true 
	for grid_pos in spawned_fragiles.keys():
		var fragile = spawned_fragiles[grid_pos]
		if is_instance_valid(fragile) and fragile.has_method("reset_to_editor"):
			fragile.reset_to_editor()
		layer_floor.set_cell(grid_pos, TileSkinData.GRASS_SOURCE_ID, Vector2i(14, 0))
	for grid_pos in spawned_hiddens.keys():
		var hidden_block = spawned_hiddens[grid_pos]
		if is_instance_valid(hidden_block) and hidden_block.has_method("reset_to_editor"):
			hidden_block.reset_to_editor()
		layer_floor.set_cell(grid_pos, TileSkinData.GRASS_SOURCE_ID, Vector2i(14, 0))
	for plat_way_inst in spawned_platforms.values():
		if is_instance_valid(plat_way_inst):
			var plat_area = plat_way_inst.get_node_or_null("New_Platform") 
			if plat_area != null and plat_area.has_method("reset_to_editor"):
				plat_area.reset_to_editor()
	for door in get_tree().get_nodes_in_group("Doors"):
		door.queue_free()
	for data in temp_doors_save:
		var new_door = DOOR_SCENE.instantiate()
		if not data["keys"].is_empty():
			new_door.debug_keys_coords = data["keys"]
		map_node.add_child(new_door)
		new_door.global_position = layer_floor.map_to_local(data["pos"])
	temp_doors_save.clear()

func _on_player_area_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and is_moving:
		if event.pressed:
			is_dragging_player = true
			player_drag_start_pos = sprite_player.global_position
			get_viewport().set_input_as_handled()

func _on_arrival_area_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and is_moving:
		if event.pressed:
			is_dragging_arrival = true
			arrival_drag_start_pos = sprite_arrival.global_position
			get_viewport().set_input_as_handled()

# ==============================================================================
# --- GESTION DES DÉPLACEMENTS (GLISSER-DÉPOSER INTERACTIFS) ---
# ==============================================================================
func _input(event: InputEvent) -> void:
	if has_node("InteractiveManager"):
		$InteractiveManager.handle_drag_input(event)

# ... [Garder apply_skin_to_fragile / hidden, spawn / remove fragiles et hiddens, is_player_stable INTACTS] ...
func apply_skin_to_fragile(fragile_node: Node2D) -> void:
	if layer_fragile == null: return
	var grid_pos = layer_fragile.local_to_map(fragile_node.position)
	var theme = cell_themes.get(grid_pos, "_fragreen")
	var skin_key = "fragile_wood" if theme == "_frawood" else "fragile_dark"
	var skin_data = $TileManager.get_skin_element("", skin_key, "")
	if skin_data == null: return
	var atlas_data = $TileManager.get_tile_variation(grid_pos, skin_data, skin_key)
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
			fragile_node.set_skin(base_texture, final_coords,true)
		else:
			fragile_node.set_skin(base_texture, final_coords,false)

func apply_skin_to_hidden(hidden_node: Node2D) -> void:
	if layer_hidden == null: return
	var grid_pos = layer_hidden.local_to_map(hidden_node.position)
	var skin_key = "hidden"
	var skin_data = $TileManager.get_skin_element("", skin_key, "")
	if skin_data == null: return
	var atlas_data = $TileManager.get_tile_variation(grid_pos, skin_data, skin_key)
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

func _spawn_fragile(grid_pos: Vector2i, target_theme: String) -> void:
	_remove_fragile(grid_pos)
	_remove_hidden(grid_pos)
	cell_themes[grid_pos] = target_theme
	layer_floor.set_cell(grid_pos, TileSkinData.GRASS_SOURCE_ID, Vector2i(14,0))
	layer_wall.set_cell(grid_pos, -1)
	layer_ice.set_cell(grid_pos, -1)
	if layer_fragile != null:
		var fragile = FRAGILE_SCENE.instantiate()
		fragile.position = layer_fragile.map_to_local(grid_pos)
		layer_fragile.add_child(fragile)
		spawned_fragiles[grid_pos] = fragile
		apply_skin_to_fragile(fragile)

func _remove_fragile(grid_pos: Vector2i) -> void:
	if spawned_fragiles.has(grid_pos):
		if is_instance_valid(spawned_fragiles[grid_pos]):
			spawned_fragiles[grid_pos].queue_free()
		spawned_fragiles.erase(grid_pos)
		if layer_fragile != null:
			layer_fragile.set_cell(grid_pos, -1)

func _spawn_hidden(grid_pos: Vector2i, target_theme: String) -> void:
	_remove_hidden(grid_pos)
	_remove_fragile(grid_pos)
	cell_themes[grid_pos] = target_theme
	layer_floor.set_cell(grid_pos, TileSkinData.GRASS_SOURCE_ID, Vector2i(14,0))
	layer_wall.set_cell(grid_pos, -1)
	layer_ice.set_cell(grid_pos, -1)
	if layer_hidden != null:
		var hidden_inst = HIDDEN_SCENE.instantiate()
		hidden_inst.position = layer_hidden.map_to_local(grid_pos)
		layer_hidden.add_child(hidden_inst)
		hidden_inst.sprite.scale = Vector2.ONE
		spawned_hiddens[grid_pos] = hidden_inst
		apply_skin_to_hidden(hidden_inst)

func _remove_hidden(grid_pos: Vector2i) -> void:
	if spawned_hiddens.has(grid_pos):
		if is_instance_valid(spawned_hiddens[grid_pos]):
			spawned_hiddens[grid_pos].queue_free()
		spawned_hiddens.erase(grid_pos)
		if layer_hidden != null:
			layer_hidden.set_cell(grid_pos, -1)

func _is_player_stable(case = layer_floor.local_to_map(sprite_player.global_position)) -> bool:
	if layer_floor.get_cell_source_id(case) != -1 and not spawned_fragiles.has(case):
		return true
	return false

# ==============================================================================
# --- GESTION DU TESTER & RECHARGEMENT DU NIVEAU DEPUIS LE JSON ---
# ==============================================================================

func lancer_scene_test() -> void:
	sauvegarder_niveau()
	self.visible = false
	self.process_mode = Node.PROCESS_MODE_DISABLED
	ui_layer.process_mode = Node.PROCESS_MODE_ALWAYS
	if is_instance_valid(instance_scene_test):
		instance_scene_test.free()
	instance_scene_test = SCENE_TEST.instantiate()
	get_tree().root.add_child(instance_scene_test)
	instance_scene_test.visible = true
	instance_scene_test.process_mode = Node.PROCESS_MODE_INHERIT
	instance_scene_test.charger_et_generer(current_file_path)

func quitter_scene_test() -> void:
	get_tree().call_group("UI_Arrival", "queue_free")
	if is_instance_valid(instance_scene_test):
		instance_scene_test.free()
		instance_scene_test = null
	self.visible = true
	self.process_mode = Node.PROCESS_MODE_INHERIT
	ui_layer.process_mode = Node.PROCESS_MODE_INHERIT
	charger_editeur_depuis_json(current_file_path)
	if camera != null:
		camera.make_current()

func sauvegarder_niveau() -> void:
	if has_node("SaveLoadManager"):
		$SaveLoadManager.sauvegarder_niveau()

func charger_editeur_depuis_json(chemin_json: String) -> void:
	if has_node("SaveLoadManager"):
		$SaveLoadManager.charger_editeur_depuis_json(chemin_json)

# ==============================================================================
# --- GESTION DES INTERACTIFS (PORTES, PLATEFORMES, PORTAILS) ---
# ==============================================================================

func _is_cell_completely_empty(grid_pos: Vector2i, ignore_platforms: bool = false) -> bool:
	if has_node("InteractiveManager"):
		return $InteractiveManager._is_cell_completely_empty(grid_pos, ignore_platforms)
	return false

func _get_platform_at(grid_pos: Vector2i) -> Node2D:
	if has_node("InteractiveManager"):
		return $InteractiveManager._get_platform_at(grid_pos)
	return null

func _stop_configuring_interactive() -> void:
	if has_node("InteractiveManager"):
		$InteractiveManager._stop_configuring_interactive()

func _inverse_path() -> void:
	if has_node("InteractiveManager"):
		$InteractiveManager._inverse_path()
