extends Control

@onready var Canvas_layer = $CanvasLayer
@onready var grid_container: GridContainer = $CanvasLayer/ScrollContainer/GridContainer
@onready var color_rect: ColorRect = $CanvasLayer/ColorRect

@export var number_of_quest : int
@export var pack_name : String
@export var is_finished : bool

@export var Vposition : Vector2
var tween : Tween
func _ready() -> void:
	
	Canvas_layer.visible = true
	$CanvasLayer/ColorRect.visible = false
	Canvas_layer.layer = 1
	
	if pack_name:
		$AutoSizeLabel.text = pack_name
	verif_quest()
	
	if verif_quest() == grid_container.get_child_count():
		is_finished = true
		$ColorRect.visible = true
	
	print($".".position)
	# repositionnez pour l'animation
	for i in range(grid_container.get_child_count()):
		var quest_slot = grid_container.get_child(i)
		quest_slot.offset_transform_position = -quest_slot.Vposition + $"../..".position + Vector2(-3,-2.5) + Vposition


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
		if color_rect.visible == true:
			color_rect.visible = false

func _on_pressed() -> void:
	if color_rect.visible == true:
		color_rect.visible = false
	else :
		color_rect.visible = true


func _on_focus_entered() -> void:
	pass


func _on_focus_exited() -> void:
	pass # Replace with function body.


func _on_mouse_entered() -> void:
	print("er")
	for i in range(3):
		var quest_slot = grid_container.get_child(i)
		if tween : tween.kill()
		tween = create_tween()
		tween.tween_property(quest_slot,"offset_transform_rotation" , 0.2 * i + 0.1, 0.2)
		await tween.finished


func _on_mouse_exited() -> void:
	for i in range(3):
		var quest_slot = grid_container.get_child(i)
		if tween : tween.kill()
		tween = create_tween()
		tween.tween_property(quest_slot,"offset_transform_rotation" , 0, 0.1)
		await tween.finished
