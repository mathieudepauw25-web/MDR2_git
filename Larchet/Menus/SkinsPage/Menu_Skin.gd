extends Control
class_name MenuSkin

@onready var grid_container: GridContainer = $GridContainer
@onready var back: Button = $Back
@onready var suivant: Button = $Suivant
@onready var precedent: Button = $Precedent
@onready var cat_controler: Control = $Cat_Zone
@onready var cat: AnimatedSprite2D = $Cat_Zone/Cat

const SKIN_SLOT_SCENE = preload("res://Larchet/Menus/SkinsPage/Skin_Slot.tscn")

var current_page: int = 0
var skins_per_page: int = 8
var is_cat_hovered: bool = false
var is_mouse_active: bool = true


func _ready() -> void:
	cat.play("Idle")
	for button in [back, suivant, precedent]:
		button.mouse_entered.connect(_on_button_hover)
		button.focus_entered.connect(_on_button_hover)
	update_menu()

func update_menu() -> void:
	cat_controler.visible = current_page == 0
	for child in grid_container.get_children():
		child.queue_free()
	var unlocked_list: Array = []
	var locked_list: Array = []
	for skin_data in GESTIONNAIRESKIN.catalog.all_skins:
		if GESTIONNAIRESKIN.player_data.unlocked_skins.has(skin_data.skin_id):
			unlocked_list.append(skin_data)
		else:
			locked_list.append(skin_data)
	var display_skins: Array = unlocked_list + locked_list
	var total_skins = display_skins.size()
	var start_index = current_page * skins_per_page
	var end_index = min(start_index + skins_per_page, total_skins)
	for i in range(start_index, end_index):
		var skin_data = display_skins[i]
		var is_unlocked = GESTIONNAIRESKIN.player_data.unlocked_skins.has(skin_data.skin_id)
		var is_equipped = GESTIONNAIRESKIN.player_data.equipped_skin == skin_data.skin_id
		var slot_instance = SKIN_SLOT_SCENE.instantiate() as SkinSlot
		grid_container.add_child(slot_instance)
		slot_instance.setup(skin_data, is_unlocked, is_equipped)
		if is_unlocked:
			slot_instance.pressed.connect(_on_skin_slot_pressed.bind(skin_data.skin_id))
		if i == start_index:
			slot_instance.grab_focus.call_deferred()
	precedent.visible = current_page > 0
	suivant.visible = end_index < total_skins


func _on_suivant_pressed() -> void:
	$%Select.play()
	current_page += 1
	update_menu()

func _on_back_pressed() -> void:
	$%Select.play()
	get_tree().change_scene_to_file("res://TitleScreen/TitleScreen.tscn")

func _on_precedent_pressed() -> void:
	$%Select.play()
	current_page -= 1
	update_menu()

func _on_skin_slot_pressed(clicked_skin_id: String) -> void:
	GESTIONNAIRESKIN.equip_skin(clicked_skin_id)
	for slot in grid_container.get_children():
		if slot is SkinSlot:
			slot.equipped_indicator.visible = slot.skin_id == clicked_skin_id

func _on_cat_mouse_entered() -> void:
	is_cat_hovered = true
	cat.play("Furie")

func _on_cat_mouse_exited() -> void:
	is_cat_hovered = false
	await get_tree().create_timer(0.5).timeout
	if not is_cat_hovered:
		cat.play("Idle")

func _on_button_hover() -> void:
	$%Move.play()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		$%Select.play()
		_on_back_pressed()
	if event is InputEventMouseMotion:
		if not is_mouse_active:
			is_mouse_active = true
			var current_focus = get_viewport().gui_get_focus_owner()
			if current_focus:
				current_focus.release_focus()
	elif event.is_action_pressed("ui_left") or event.is_action_pressed("ui_right") or event.is_action_pressed("ui_up") or event.is_action_pressed("ui_down"):
		if get_viewport().gui_get_focus_owner() == null:
			if grid_container.get_child_count() > 0:
				grid_container.get_child(0).grab_focus()
			else:
				back.grab_focus()
