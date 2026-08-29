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
	
	panel.offset_transform_scale = Vector2(1.5,1.5)
	
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(panel, "offset_transform_scale", Vector2(0.9,0.9), 0.1)
	tween.tween_property(panel, "offset_transform_scale", Vector2(1,1), 0.1)
