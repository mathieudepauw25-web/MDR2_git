extends Control

@onready var Canvas_layer = $CanvasLayer
@onready var grid_container: GridContainer = $CanvasLayer/ScrollContainer/GridContainer

@export var number_of_quest : int
@export var pack_name : String
@export var is_finished : bool


func _ready() -> void:
	if pack_name:
		$AutoSizeLabel.text = pack_name
	verif_quest()
	
	if verif_quest() == grid_container.get_child_count():
		is_finished = true
		$ColorRect.visible = true
		
func verif_quest():
	var count = 0
	print("le grid container contient: " + str(grid_container.get_child_count()))
	for i in range(grid_container.get_child_count()):
		var quest_slot = grid_container.get_child(i)
		if quest_slot.quest_finish == false:
			print("range break")
			break
		count += 1
		print(count)
	return count
		


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("escape"):
		if Canvas_layer.visible == true:
			Canvas_layer.visible = false

func _on_pressed() -> void:
	if Canvas_layer.visible == true:
		Canvas_layer.visible = false
	else :
		Canvas_layer.visible = true
