extends Node2D
class_name Dashspot

@onready var node_tile_map_layer_floor: TileMapLayer = %tileMapLayer_floor
@onready var node_tile_map_layer_wall: TileMapLayer = %tileMapLayer_wall
@onready var node_tile_map_layer_ice: TileMapLayer = %tileMapLayer_ice

@onready var node_point_light_2d: PointLight2D = %PointLight2D


enum dspotDirection{
	RIGHT, 
	UP, 
	LEFT, 
	DOWN
}

@export var dspot_direction: dspotDirection


func _ready() -> void :
	EVENTS.connect("show_Dspot", _on_EVENTS_show_Dspot)
	EVENTS.connect("hide_Dspot", _on_EVENTS_hide_Dspot)

func calcul_decal_position(decal: int = 1) -> Vector2:
	var spot_direction = Vector2.ZERO
	var new_position = global_position
	match dspot_direction:
		dspotDirection.RIGHT: spot_direction = Vector2.RIGHT
		dspotDirection.UP: spot_direction = Vector2.UP
		dspotDirection.LEFT: spot_direction = Vector2.LEFT
		dspotDirection.DOWN: spot_direction = Vector2.DOWN

	new_position += spot_direction * (16 * decal)

	return new_position

func _on_EVENTS_show_Dspot(starting_position: Vector2) -> void :
	global_position = starting_position

	for n in 3:
		var Stempo_position = calcul_decal_position(n + 1)
		var Stile_check: = node_tile_map_layer_wall.local_to_map(Stempo_position)
		if node_tile_map_layer_wall.get_cell_source_id(Stile_check) != -1:
			visible = false
			return

	var tempo_position = calcul_decal_position(4)
	var tile_check: = node_tile_map_layer_floor.local_to_map(tempo_position)


	if node_tile_map_layer_ice.get_cell_source_id(tile_check) != -1:
		visible = false
		return


	if node_tile_map_layer_floor.get_cell_source_id(tile_check) != -1:
		global_position = tempo_position
		visible = true
		node_point_light_2d.scale = Vector2.ZERO
		var tween = create_tween()
		tween.tween_property(node_point_light_2d, "scale", Vector2.ONE, 0.12).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)

func _on_EVENTS_hide_Dspot() -> void :
	visible = false
