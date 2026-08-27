extends Button
@onready var progress_bar: ProgressBar = $ProgressBar

@export var quest_finish = false
@export var has_slider = false

@export var quest_name : String
@export var descrition : String
@export var in_pack : String
@export var what_to_look : String
@export var objectif : int

@export var Vposition : Vector2

func _ready() -> void:
	if GAMEDATA.get(what_to_look) >= objectif:
		print(GAMEDATA.get(what_to_look))
		quest_finish = true
	else:
		print(what_to_look)
		print(quest_finish)
		

	if has_slider == true:
		progress_bar.visible = true
		progress_bar.max_value = objectif
		progress_bar.value = GAMEDATA.get(what_to_look)
	
	
	
	if quest_name and descrition:
		$Quest_name.text = quest_name
		$Description.text = descrition
	

		
	if quest_finish == true:
		$ColorRect.visible = true
