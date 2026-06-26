extends Control

const CONTROL_SLOT_SCENE = preload("res://Larchet/Menus/ControlsPage/Scenes/Control_Slot.tscn")

@onready var colonne_gauche: VBoxContainer = $MarginContainer/HBoxContainer/ColonneGauche
@onready var colonne_droite: VBoxContainer = $MarginContainer/HBoxContainer/ColonneDroite

@export var config_remap: ControlsConfig

var is_remapping: bool = false
var action_to_remap: String = ""
var slot_to_update: ControlSlot = null


func _ready() -> void:
	if config_remap:
		generate_slots()

func generate_slots() -> void:
	var total_actions = config_remap.action_list.size()
	var half_point = ceil(total_actions / 2.0)
	for i in range(total_actions):
		var item = config_remap.action_list[i]
		var action_id = item["action_id"]
		var display_name = item["display_name"]
		var slot_instance = CONTROL_SLOT_SCENE.instantiate() as ControlSlot
		if i < half_point:
			colonne_gauche.add_child(slot_instance)
		else:
			colonne_droite.add_child(slot_instance)
		var current_key = get_current_key_name(action_id)
		slot_instance.setup(action_id, display_name, current_key)
		slot_instance.gui_input.connect(_on_slot_gui_input.bind(slot_instance))
		if i == 0:
			slot_instance.grab_focus.call_deferred()

func get_current_key_name(action_id: String) -> String:
	var events = InputMap.action_get_events(action_id)
	if events.size() > 0:
		return events[0].as_text().trim_suffix(" (Physical)")
	return "..."

func _on_slot_gui_input(event: InputEvent, slot: ControlSlot) -> void:
	var wants_to_remap: bool = false
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.double_click and event.pressed:
			%Select.play()
			wants_to_remap = true
			slot.accept_event()
	elif event.is_action_pressed("ui_accept"):
		%Select.play()
		wants_to_remap = true
	if wants_to_remap:
		if is_remapping: return 
		is_remapping = true
		action_to_remap = slot.action_id
		slot_to_update = slot
		slot_to_update.update_key_text("...")

func _input(event: InputEvent) -> void:
	if is_remapping:
		if event is InputEventKey and event.pressed and not event.is_echo():
			if event.keycode == KEY_ESCAPE:
				slot_to_update.update_key_text(get_current_key_name(action_to_remap))
				is_remapping = false
				get_viewport().set_input_as_handled()
				return
			var all_slots = colonne_gauche.get_children() + colonne_droite.get_children()
			
			for slot in all_slots:
				if slot != slot_to_update:
					if event.is_action(slot.action_id):
						InputMap.action_erase_events(slot.action_id)
						slot.update_key_text("...")
			InputMap.action_erase_events(action_to_remap)
			InputMap.action_add_event(action_to_remap, event)
			var new_key_name = event.as_text().trim_suffix(" (Physical)")
			slot_to_update.update_key_text(new_key_name)
			is_remapping = false
			get_viewport().set_input_as_handled()
			%Validation.play()
			save_controls()
	elif event.is_action_pressed("ui_cancel"):
		_on_back_pressed()

func save_controls() -> void:
	var config = ConfigFile.new()
	for item in config_remap.action_list:
		var action_id = item["action_id"]
		var events = InputMap.action_get_events(action_id)
		if events.size() > 0:
			config.set_value("Controls", action_id, events[0])
	config.save("user://controls.cfg")

func _on_back_pressed() -> void:
	$%Select.play()
	get_tree().change_scene_to_file("res://TitleScreen/TitleScreen.tscn")

func _on_back_hover() -> void:
	$%Move.play()
