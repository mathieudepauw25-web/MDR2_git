extends Node2D

@onready var map_node: Node2D = $MAP
@onready var layer_wall: TileMapLayer = %tileMapLayer_floor
@onready var layer_ice: TileMapLayer = %tileMapLayer_ice

enum Brush { WALL, ICE, ERASER }
var current_brush: Brush = Brush.WALL
var current_source_id: int = 0
var current_atlas_coords: Vector2i = Vector2i(0, 0)


func _ready() -> void:
	var btn_mur = $UI_Layer/PanelContainer/VBoxContainer/Btn_Mur
	var btn_glace = $UI_Layer/PanelContainer/VBoxContainer/Btn_Glace
	var btn_gomme = $UI_Layer/PanelContainer/VBoxContainer/Btn_Gomme
	btn_mur.pressed.connect(func(): current_brush = Brush.WALL)
	btn_glace.pressed.connect(func(): current_brush = Brush.ICE)
	btn_gomme.pressed.connect(func(): current_brush = Brush.ERASER)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion or event is InputEventMouseButton:
		var is_left_clicking = Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
		var is_right_clicking = Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT)
		if is_left_clicking:
			paint_smart_tile()
		elif is_right_clicking:
			erase_all_layers()

func paint_smart_tile() -> void:
	var mouse_pos = get_global_mouse_position()
	var grid_pos = layer_wall.local_to_map(mouse_pos)
	match current_brush:
		Brush.WALL:
			layer_wall.set_cell(grid_pos, 0, Vector2i(0, 0))
		Brush.ICE:
			layer_ice.set_cell(grid_pos, 0, Vector2i(0, 0))
		Brush.ERASER:
			erase_all_layers(grid_pos)

func erase_all_layers(specific_pos = null) -> void:
	var grid_pos = specific_pos
	if grid_pos == null:
		var mouse_pos = get_global_mouse_position()
		grid_pos = layer_wall.local_to_map(mouse_pos)
	layer_wall.set_cell(grid_pos, -1)
	layer_ice.set_cell(grid_pos, -1)
