extends Area2D
class_name New_Door

var node_map: TileMapLayer
var node_tile_map_layer_wall: TileMapLayer

@onready var node_bulle: TextureRect = %Bulle
@onready var node_label: Label = %Label
@onready var nb_keys: Label = %nb_keys

@export var position_show: = Vector2(-11.0, -20.0)
@export var position_hide: = Vector2(-11.0, -6.0)
@export var debug_keys_coords: Array[Vector2] = [] 

var nb_keys_needed: = 1
var nb_key: = 0
var player_in_range: = false

func _init_maps() -> void:
	if node_map != null and node_tile_map_layer_wall != null:
		return
	var root = get_tree().current_scene
	node_map = root.find_child("tileMapLayer_floor", true, false)
	if node_map == null:
		node_map = root.find_child("MAP", true, false)
	node_tile_map_layer_wall = root.find_child("tileMapLayer_wall", true, false)

func _ready() -> void :
	add_to_group("Doors")
	_init_maps()
	var keys_container = get_node_or_null("Keys")
	if keys_container:
		keys_container.set_as_top_level(true)
		keys_container.global_position = Vector2.ZERO
	if not debug_keys_coords.is_empty():
		generate_keys(debug_keys_coords)
	node_bulle.position = position_hide
	node_bulle.scale = Vector2.ZERO
	node_bulle.visible = false
	node_label.text = str(nb_key)
	nb_keys.text = str(nb_keys_needed)

func generate_keys(coords_list: Array) -> void:
	if coords_list.is_empty():
		return
	_init_maps()
	var safe_coords = coords_list.duplicate()
	debug_keys_coords.clear() 
	var keys_container = get_node_or_null("Keys")
	if keys_container == null or keys_container.get_child_count() == 0:
		return
	var base_key: Keys = keys_container.get_children()[0]
	var first_key_coord = Vector2i(safe_coords[0].x, safe_coords[0].y)
	base_key.global_position = node_map.map_to_local(first_key_coord)
	debug_keys_coords.append(first_key_coord)
	for i in range(1, safe_coords.size()):
		generate_one_key(Vector2i(safe_coords[i].x, safe_coords[i].y))
	update_key_display()

func generate_one_key(coord: Vector2i):
	_init_maps()
	var keys_container = get_node_or_null("Keys")
	var base_key: Keys = keys_container.get_children()[0]
	var new_key = base_key.duplicate()
	keys_container.add_child(new_key)
	new_key.global_position = node_map.map_to_local(coord)
	debug_keys_coords.append(coord)
	update_key_display()

func update_key_display() -> void:
	nb_keys_needed = debug_keys_coords.size()
	nb_keys.text = str(nb_keys_needed)

# ----- Fonctionnement -----

func open_door() -> void :
	if node_tile_map_layer_wall != null:
		node_tile_map_layer_wall.erase_cell(node_map.local_to_map(global_position))
	var my_pos = node_map.local_to_map(global_position)
	get_tree().call_group("LinkedPlatforms", "check_door_opened", my_pos)
	queue_free()

func gain_key() -> void :
	nb_key += 1
	node_label.text = str(nb_key)
	if nb_key >= nb_keys_needed:
		open_door()

func _on_area_entered(area: Area2D) -> void :
	if area is Keys and area.node_door == self and area.collected:
		gain_key()
		area.queue_free()

func _on_detect_show_area_entered(area: Area2D) -> void :
	if area is Player:
		player_in_range = true
		node_bulle.visible = true
		var tween = create_tween().set_parallel()
		tween.tween_property(node_bulle, "position", position_show, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
		tween.tween_property(node_bulle, "scale", Vector2.ONE, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)

func _on_detect_show_area_exited(area: Area2D) -> void :
	if area is Player:
		player_in_range = false
		var tween = create_tween().set_parallel()
		tween.tween_property(node_bulle, "position", position_hide, 0.3).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
		tween.tween_property(node_bulle, "scale", Vector2.ZERO, 0.3).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
		tween.connect("finished", _on_tween_finished)

func _on_tween_finished() -> void :
	if player_in_range == false:
		node_bulle.visible = false
