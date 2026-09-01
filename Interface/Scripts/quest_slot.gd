extends Button
@onready var progress_bar: ProgressBar = $ProgressBar

@export var quest_finish = false
@export var has_slider = false

@export var quest_name : String
@export var descrition : String
@export var in_pack : String
@export var what_to_look : String
@export var objectif : int
@onready var panel: Panel = $ColorRect/Panel

var tween : Tween
func _ready() -> void:
	if GAMEDATA.get(what_to_look) >= objectif:
		quest_finish = true

	if has_slider == true:
		progress_bar.visible = true
		progress_bar.max_value = objectif
		progress_bar.value = GAMEDATA.get(what_to_look)
	
	if quest_name and descrition:
		$Quest_name.text = quest_name
		$Description.text = descrition
		
	if quest_finish == true:
		$ColorRect.visible = true



func finish_anim():
	print("anim")
	panel.visible = false
	await get_tree().create_timer(0.2).timeout
	panel.offset_transform_scale = Vector2(2,2)
	panel.visible = true
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(panel, "offset_transform_scale", Vector2(0.9,0.9), 0.1)
	tween.tween_property(panel, "offset_transform_scale", Vector2(1,1), 0.1)

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("escape"):
		panel.visible = false
