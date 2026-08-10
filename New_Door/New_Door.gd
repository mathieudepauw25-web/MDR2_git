extends Area2D
class_name New_Door

@onready var node_map: TileMapLayer = %MAP
@onready var node_tile_map_layer_wall: TileMapLayer = %tileMapLayer_wall
@onready var node_bulle: TextureRect = %Bulle
@onready var node_label: Label = %Label
@onready var nb_keys: Label = %nb_keys

@export var index_door: = 0
@export var position_show: = Vector2(-11.0, -20.0)
@export var position_hide: = Vector2(-11.0, -6.0)
@export var debug_keys_coords: Array[Vector2] = [] 

var nb_keys_needed: = 1
var nb_key: = 0
var player_in_range: = false

func _ready() -> void :
	add_to_group("Doors")
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
	debug_keys_coords.clear() 
	var keys_container = get_node_or_null("Keys")
	var base_key: Keys = keys_container.get_children()[0]
	var door_tile = node_map.local_to_map(global_position)
	var first_key_coord = Vector2i(coords_list[0].x, coords_list[0].y)
	base_key.global_position = node_map.map_to_local(door_tile + first_key_coord)
	debug_keys_coords.append(first_key_coord)
	for i in range(1, coords_list.size()):
		generate_one_key(Vector2i(coords_list[i].x, coords_list[i].y))
	update_key_display()

func generate_one_key(coord: Vector2i):
	var keys_container = get_node_or_null("Keys")
	var base_key: Keys = keys_container.get_children()[0]
	var new_key = base_key.duplicate()
	keys_container.add_child(new_key)
	var key_tile = node_map.local_to_map(global_position) + Vector2i(coord.x, coord.y)
	new_key.global_position = node_map.map_to_local(key_tile)
	debug_keys_coords.append(coord)
	update_key_display()

func update_key_display() -> void:
	nb_keys_needed = debug_keys_coords.size()
	nb_keys.text = str(nb_keys_needed)

func can_place_door_or_key(tile_pos: Vector2i) -> bool:
	var layer_floor = node_map.get_node_or_null("tileMapLayer_floor")
	if layer_floor == null or layer_floor.get_cell_source_id(tile_pos) == -1:
		return false
	var player = get_node_or_null("%Player")
	if player and node_map.local_to_map(player.global_position) == tile_pos:
		return false
	for arrival in get_tree().get_nodes_in_group("Arrival"):
		if node_map.local_to_map(arrival.global_position) == tile_pos:
			return false
	var interactives = get_tree().get_nodes_in_group("Doors") + get_tree().get_nodes_in_group("Platforms")
	for node in interactives:
		if node_map.local_to_map(node.global_position) == tile_pos:
			return false
		if node is New_Door:
			var keys_container = node.get_node_or_null("Keys")
			if keys_container:
				for key in keys_container.get_children():
					if node_map.local_to_map(key.global_position) == tile_pos:
						return false
	return true

func get_nearest_valid_tile(start_tile: Vector2i) -> Vector2i:
	var max_radius: = 10
	for r in range(1, max_radius):
		for x in range(-r, r + 1):
			for y in range(-r, r + 1):
				if abs(x) == r or abs(y) == r:
					var check_tile = start_tile + Vector2i(x, y)
					if can_place_door_or_key(check_tile):
						return check_tile
	return start_tile

# ----- Fonctionnement -----

func open_door() -> void :
	print(self.name + " Open")
	node_tile_map_layer_wall.erase_cell(node_map.local_to_map(global_position))
	if index_door == 2:
		EVENTS.emit_signal("door2")
	queue_free()

func gain_key() -> void :
	nb_key += 1
	node_label.text = str(nb_key)
	if nb_key >= nb_keys_needed:
		open_door()

func _on_area_entered(area: Area2D) -> void :
	if area is Keys and area.node_door == self:
		gain_key()

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
