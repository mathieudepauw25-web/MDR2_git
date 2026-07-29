extends CanvasLayer

signal brush_selected(brush_type: TileSkinData.Brush)
signal grass_mode_toggled(new_mode: int)
signal mode3_toggled()

@onready var lbl_coords: Label = $Coordonnees
@onready var lbl_grass_mode: Label = $grass_mode/Label
@onready var lbl_OL: Label = $Btn_Open_Locked/Label
@onready var lbl_test: Label = $Btn_Test/Label
@onready var lbl_move: Label = $Btn_Move/Label
@onready var btn_grass_mode: Button = %grass_mode
@onready var btn_mode3: Button = %Btn_Mode3
@onready var btn_OL: Button = %Btn_Open_Locked
@onready var btn_test: Button = %Btn_Test
@onready var btn_move: Button = %Btn_Move
@onready var btn_herbe = $PanelContainer/HBoxContainer/Btn_Herbe
@onready var btn_mur = $PanelContainer/HBoxContainer/Btn_Mur
@onready var btn_glace = $PanelContainer/HBoxContainer/Btn_Glace
@onready var btn_transparent = $PanelContainer/HBoxContainer/Btn_Transparent
@onready var btn_bridge = $PanelContainer/HBoxContainer/Btn_Bridge
@onready var btn_fragile_green = $PanelContainer/HBoxContainer/Btn_Fragile_Green
@onready var btn_fragile_wood = $PanelContainer/HBoxContainer/Btn_Fragile_Wood
@onready var btn_hidden = $PanelContainer/HBoxContainer/Btn_Hidden
@onready var grid = $"../MAP/GridVisualizer"

var grass_mode: int = 1
var is_locked: bool = false

func _ready() -> void:
	var brush_group = ButtonGroup.new()
	btn_herbe.button_group = brush_group
	btn_mur.button_group = brush_group
	btn_glace.button_group = brush_group
	btn_transparent.button_group = brush_group
	btn_bridge.button_group = brush_group
	btn_fragile_green.button_group = brush_group
	btn_fragile_wood.button_group = brush_group
	btn_hidden.button_group = brush_group
	btn_herbe.pressed.connect(func(): brush_selected.emit(TileSkinData.Brush.GRASS))
	btn_mur.pressed.connect(func(): brush_selected.emit(TileSkinData.Brush.WALL))
	btn_glace.pressed.connect(func(): brush_selected.emit(TileSkinData.Brush.ICE))
	btn_transparent.pressed.connect(func(): brush_selected.emit(TileSkinData.Brush.TRANS))
	btn_bridge.pressed.connect(func(): brush_selected.emit(TileSkinData.Brush.BRIDGE))
	btn_fragile_green.pressed.connect(func(): brush_selected.emit(TileSkinData.Brush.FRAGREEN))
	btn_fragile_wood.pressed.connect(func(): brush_selected.emit(TileSkinData.Brush.FRAWOOD))
	btn_hidden.pressed.connect(func(): brush_selected.emit(TileSkinData.Brush.HIDDEN))
	btn_grass_mode.pressed.connect(_on_grass_mode_pressed)
	btn_herbe.button_pressed = true
	if not btn_mode3.pressed.is_connected(_on_mode3_pressed):
		btn_mode3.pressed.connect(_on_mode3_pressed)
	btn_mode3.visible = false
	btn_OL.pressed.connect(_on_OL_pressed)
	btn_test.pressed.connect(_on_test_pressed)
	btn_move.pressed.connect(_on_move_pressed)

func _on_grass_mode_pressed() -> void:
	grass_mode = 1 if grass_mode == 3 else grass_mode + 1
	lbl_grass_mode.text = str(grass_mode)
	if grass_mode == 3:
		btn_mode3.show()
	else:
		btn_mode3.hide()
	grass_mode_toggled.emit(grass_mode)

func _on_OL_pressed() -> void:
	if lbl_OL.text == "L":
		lbl_OL.text = "O"
		is_locked = false
	else:
		lbl_OL.text = "L"
		is_locked = true

func _on_mode3_pressed() -> void:
	mode3_toggled.emit()
	btn_herbe.button_pressed = true
	brush_selected.emit(TileSkinData.Brush.GRASS)

func update_coords(x: int, y: int) -> void:
	lbl_coords.text = "X: %d, Y: %d" % [x, y]

func _on_test_pressed() -> void:
	if lbl_test.text == ">":
		lbl_test.text = "="
		for UI in self.get_children():
			if UI != btn_test:
				UI.visible = false
		grid.visible = false
		get_parent().play_map()
	else:
		lbl_test.text = ">"
		for UI in self.get_children():
			if UI != %PatternWindow and UI != btn_mode3:
				UI.visible = true
		if lbl_grass_mode.text == "3":
			btn_mode3.visible = true
		grid.visible = true
		get_parent().back_to_editor()

func _on_move_pressed() -> void:
	if lbl_move.text == "=":
		lbl_move.text = "M"
		$"..".is_moving = true
	else:
		lbl_move.text = "="
		$"..".is_moving = false
