extends Node2D

@onready var map_node: Node2D = $MAP
@onready var layer_wall: TileMapLayer = %tileMapLayer_floor
@onready var layer_ice: TileMapLayer = %tileMapLayer_ice
@onready var camera: Camera2D = $Camera2D
@onready var lbl_coords: Label = $UI_Layer/Coordonnees

enum Brush { WALL, ICE, ERASER }
var current_brush: Brush = Brush.WALL
var current_source_id: int = 0
var current_atlas_coords: Vector2i = Vector2i(0, 0)
var is_panning: bool = false

var zoom_min: float = 0.2
var zoom_max: float = 3.0
var zoom_speed: float = 0.1

func _ready() -> void:
	var btn_mur = $UI_Layer/PanelContainer/HBoxContainer/Btn_Mur
	var btn_glace = $UI_Layer/PanelContainer/HBoxContainer/Btn_Glace
	var btn_gomme = $UI_Layer/PanelContainer/HBoxContainer/Btn_Gomme
	btn_mur.pressed.connect(func(): current_brush = Brush.WALL)
	btn_glace.pressed.connect(func(): current_brush = Brush.ICE)
	btn_gomme.pressed.connect(func(): current_brush = Brush.ERASER)
	btn_mur.button_pressed = true

func _process(_delta: float) -> void:
	var center_pixel_pos = camera.global_position
	var center_grid_pos = layer_wall.local_to_map(center_pixel_pos)
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
		if is_left_clicking and not is_panning:
			paint_smart_tile()
		elif is_right_clicking and not is_panning:
			erase_all_layers()

func apply_zoom(amount: float) -> void:
	var current_zoom = camera.zoom.x
	var new_zoom = current_zoom + amount
	new_zoom = clamp(new_zoom, zoom_min, zoom_max)
	camera.zoom = Vector2(new_zoom, new_zoom)

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
