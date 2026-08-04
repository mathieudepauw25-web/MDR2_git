extends CanvasLayer

signal brush_selected(brush_type: TileSkinData.Brush)
signal grass_mode_toggled(new_mode: int)
signal mode3_toggled()

# --- NOUVEAUX SIGNAUX POUR LES MODES ---
signal edit_mode_changed(new_mode: EditMode)
signal interactive_type_changed(new_type: InteractiveType)

# --- DÉFINITION DES ÉTATS (MACHINE À ÉTATS) ---
enum EditMode { FLOOR, INTERACTIVE }
enum InteractiveType { NONE, DOOR, PLATFORM, PORTAL }

var current_edit_mode: EditMode = EditMode.FLOOR
var current_interactive_type: InteractiveType = InteractiveType.NONE

@onready var lbl_coords: Label = $Coordonnees
@onready var lbl_grass_mode: Label = $UI_simplifier/grass_mode/Label
@onready var lbl_OL: Label = $UI_simplifier/Btn_Open_Locked/Label
@onready var lbl_test: Label = $UI_simplifier/Btn_Test/Label
@onready var lbl_move: Label = $UI_simplifier/Btn_Move/Label
@onready var lbl_tester: Label = $UI_simplifier/Btn_Tester/Label

@onready var btn_grass_mode: Button = %grass_mode
@onready var btn_mode3: Button = %Btn_Mode3
@onready var btn_OL: Button = %Btn_Open_Locked
@onready var btn_test: Button = %Btn_Test
@onready var btn_save: Button = %Btn_Save
@onready var btn_move: Button = %Btn_Move
@onready var btn_tester: Button = %Btn_Tester

@onready var ui_simplifier: Control = $UI_simplifier

@onready var btn_doors: Button = $Interactive/VBoxContainer/Btn_Doors
@onready var btn_platforms: Button = $Interactive/VBoxContainer/Btn_Platforms
@onready var btn_portals: Button = $Interactive/VBoxContainer/Btn_Portals

@onready var property: PanelContainer = $Property
@onready var doors: PanelContainer = $Property/Doors
@onready var doors_spin_box: SpinBox = $Property/Doors/DoorsSpinBox
@onready var platforms: PanelContainer = $Property/Platforms
@onready var portals: PanelContainer = $Property/Portals
@onready var select_out: Button = $Property/Portals/Select_Out

@onready var selection: Panel = %Selection

@onready var btn_herbe = $Floor/HBoxContainer/Btn_Herbe
@onready var btn_mur = $Floor/HBoxContainer/Btn_Mur
@onready var btn_glace = $Floor/HBoxContainer/Btn_Glace
@onready var btn_transparent = $Floor/HBoxContainer/Btn_Transparent
@onready var btn_bridge = $Floor/HBoxContainer/Btn_Bridge
@onready var btn_fragile_green = $Floor/HBoxContainer/Btn_Fragile_Green
@onready var btn_fragile_wood = $Floor/HBoxContainer/Btn_Fragile_Wood
@onready var btn_hidden = $Floor/HBoxContainer/Btn_Hidden
@onready var grid = $"../MAP_global/GridVisualizer"

var grass_mode: int = 1
var is_locked: bool = false

func _ready() -> void:
	var brush_group = ButtonGroup.new()
	var tous_les_outils = [
		btn_herbe, btn_mur, btn_glace, btn_transparent, btn_bridge,
		btn_fragile_green, btn_fragile_wood, btn_hidden,
		btn_doors, btn_platforms, btn_portals
	]
	for btn in tous_les_outils:
		btn.button_group = brush_group
		btn.toggle_mode = true
		btn.focus_mode = Control.FOCUS_NONE
	btn_herbe.pressed.connect(_selectionner_brush.bind(TileSkinData.Brush.GRASS))
	btn_mur.pressed.connect(_selectionner_brush.bind(TileSkinData.Brush.WALL))
	btn_glace.pressed.connect(_selectionner_brush.bind(TileSkinData.Brush.ICE))
	btn_transparent.pressed.connect(_selectionner_brush.bind(TileSkinData.Brush.TRANS))
	btn_bridge.pressed.connect(_selectionner_brush.bind(TileSkinData.Brush.BRIDGE))
	btn_fragile_green.pressed.connect(_selectionner_brush.bind(TileSkinData.Brush.FRAGREEN))
	btn_fragile_wood.pressed.connect(_selectionner_brush.bind(TileSkinData.Brush.FRAWOOD))
	btn_hidden.pressed.connect(_selectionner_brush.bind(TileSkinData.Brush.HIDDEN))
	btn_grass_mode.pressed.connect(_on_grass_mode_pressed)
	btn_herbe.set_pressed_no_signal(true)
	
	if not btn_mode3.pressed.is_connected(_on_mode3_pressed):
		btn_mode3.pressed.connect(_on_mode3_pressed)
	btn_mode3.visible = false
	
	btn_OL.pressed.connect(_on_OL_pressed)
	btn_test.pressed.connect(_on_test_pressed)
	btn_save.pressed.connect(_on_save_pressed)
	btn_move.pressed.connect(_on_move_pressed)
	btn_tester.pressed.connect(_on_tester_pressed)
	btn_doors.pressed.connect(_on_doors_pressed)
	btn_platforms.pressed.connect(_on_platforms_pressed)
	btn_portals.pressed.connect(_on_portals_pressed)

# ==========================================
# GESTION DES MODES D'ÉDITION
# ==========================================

func _selectionner_brush(brush_type: TileSkinData.Brush) -> void:
	property.hide()
	current_edit_mode = EditMode.FLOOR
	current_interactive_type = InteractiveType.NONE
	edit_mode_changed.emit(current_edit_mode)
	interactive_type_changed.emit(current_interactive_type)
	
	brush_selected.emit(brush_type)

func _set_interactive_mode(type: InteractiveType) -> void:
	current_edit_mode = EditMode.INTERACTIVE
	current_interactive_type = type
	edit_mode_changed.emit(current_edit_mode)
	interactive_type_changed.emit(current_interactive_type)

func _on_doors_pressed() -> void:
	_set_interactive_mode(InteractiveType.DOOR)
	property.visible = true
	for UI in property.get_children():
		if UI != doors:
			UI.visible = false
	doors.visible = true

func _on_platforms_pressed() -> void:
	_set_interactive_mode(InteractiveType.PLATFORM)
	property.visible = true
	for UI in property.get_children():
		if UI != platforms:
			UI.visible = false
	platforms.visible = true

func _on_portals_pressed() -> void:
	_set_interactive_mode(InteractiveType.PORTAL)
	property.visible = true
	for UI in property.get_children():
		if UI != portals:
			UI.visible = false
	portals.visible = true

# ==========================================
# UI & AUTRES BOUTONS
# ==========================================

func UI_invisible(bout: Button) -> void:
	for UI in self.get_children():
		if UI == ui_simplifier:
			for btn in UI.get_children():
				if btn != bout:
					btn.visible = false
		else:
			UI.visible = false
	selection.visible = false

func UI_visible(bout: Button) -> void:
	for UI in self.get_children():
		if UI != %PatternWindow and UI != property:
			UI.visible = true
			if UI == ui_simplifier:
				for btn in UI.get_children():
					if btn != bout and btn != btn_mode3:
						btn.visible = true
	if lbl_grass_mode.text == "3":
		btn_mode3.visible = true

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
	_selectionner_brush(TileSkinData.Brush.GRASS)

func update_coords(x: int, y: int) -> void:
	lbl_coords.text = "X: %d, Y: %d" % [x, y]

func _on_test_pressed() -> void:
	if lbl_test.text == ">":
		if not get_parent()._is_player_stable():
			print("Veuillez positionner le player sur une case stable")
			return
		btn_herbe.button_pressed = true
		_selectionner_brush(TileSkinData.Brush.GRASS)
		lbl_test.text = "="
		UI_invisible(btn_test)
		get_parent().play_map()
	else:
		lbl_test.text = ">"
		UI_visible(btn_test)
		grid.visible = true
		get_parent().back_to_editor()

func _on_tester_pressed() -> void:
	if lbl_tester.text == "T":
		if not get_parent()._is_player_stable():
			print("Veuillez positionner le player sur une case stable")
			return
		lbl_tester.text = "B"
		UI_invisible(btn_tester)
		get_parent().lancer_scene_test()
	else:
		lbl_tester.text = "T"
		UI_visible(btn_tester)
		get_parent().quitter_scene_test()

func _on_move_pressed() -> void:
	if lbl_move.text == "=":
		lbl_move.text = "M"
		$"..".is_moving = true
	else:
		lbl_move.text = "="
		$"..".is_moving = false

func _on_save_pressed() -> void:
	get_parent().sauvegarder_niveau()

func sync_grass_mode(loaded_mode: int) -> void:
	grass_mode = loaded_mode
	lbl_grass_mode.text = str(grass_mode)
	if grass_mode == 3:
		btn_mode3.show()
	else:
		btn_mode3.hide()
