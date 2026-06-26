extends TileMapLayer
class_name Map



func _ready() -> void :
	EVENTS.connect("erase_floor_tile", _on_EVENTS_erase_floor_tile)
	EVENTS.connect("create_floor_tile", _on_EVENTS_create_floor_tile)
	GAMES.reset_run()

func _on_EVENTS_create_floor_tile(v_global_position: Vector2):
	var node_map_floor: TileMapLayer = get_child(0)
	var tile = node_map_floor.local_to_map(v_global_position)
	node_map_floor.set_cell(tile, 0, Vector2(19, 2), 0)

func _on_EVENTS_erase_floor_tile(v_global_position: Vector2):
	var node_map_floor: TileMapLayer = get_child(0)
	var tile = node_map_floor.local_to_map(v_global_position)
	node_map_floor.erase_cell(tile)
