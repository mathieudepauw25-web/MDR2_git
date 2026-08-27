extends Control

@onready var Canvas_layer = $CanvasLayer
@onready var grid_container: GridContainer = $CanvasLayer/ScrollContainer/GridContainer
@onready var color_rect: ColorRect = $CanvasLayer/ColorRect
@onready var progress_bar: ProgressBar = $ProgressBar

@export var number_of_quest : int
@export var pack_name : String
@export var is_finished : bool
@export var animation : String

@export var Vposition : Vector2
var tween : Tween
var in_animation = false

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
	
	
	reposition()
	
	#if animation == "up":
		#offset_transform_position = Vector2(-500, 0)
		#tween = create_tween()
		#tween.tween_property(self, "offset_transform_position", Vector2(10, 0), 0.1)
		#tween.tween_property(self, "offset_transform_position", Vector2(0, 0), 0.1)

func reposition():
	# repositionnez pour l'animation
	Canvas_layer.layer = 0
	if tween : tween.kill()
	for i in range(grid_container.get_child_count()):
		var quest_slot = grid_container.get_child(i)
		quest_slot.offset_transform_position = -quest_slot.Vposition + $"../..".position + Vector2(-3,-2.5) + Vposition


func verif_quest():
	progress_bar.max_value = grid_container.get_child_count()
	
	var count = 0
	print("le grid container contient: " + str(grid_container.get_child_count()))
	for i in range(grid_container.get_child_count()):
		progress_bar.value = count
		var quest_slot = grid_container.get_child(i)
		if quest_slot.quest_finish == false:
			break
		count += 1
		print("nbr de quetes fini: " + str(count))
	return count
	


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("escape"):
		if color_rect.visible == true:
			in_animation = false
			color_rect.visible = false
			reposition()

func _on_pressed() -> void:
	in_animation = true
	color_rect.visible = true
	Canvas_layer.layer = 2
	for i in range(grid_container.get_child_count()):
		var quest_slot = grid_container.get_child(i)
		quest_slot.visible = false
	for i in range(grid_container.get_child_count()):
		var quest_slot = grid_container.get_child(i)
		var actual_offset_position = quest_slot.offset_transform_position
		quest_slot.visible = true
		if tween : tween.kill()
		tween = create_tween()
		tween.parallel().tween_property(quest_slot,"offset_transform_rotation" , 0, 0)
		tween.tween_property(quest_slot,"offset_transform_position" , -actual_offset_position / 10 , 0.1)
		tween.tween_property(quest_slot,"offset_transform_position" , Vector2(0,0), 0.05)
		await tween.finished
		quest_slot.z_index = 0
		
	
var tween2 : Tween
func _on_mouse_entered() -> void:
	var random =  [-1.0, 1.0].pick_random()
	print(random)
	z_index = 2
	tween2 = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	var target = self
	tween2.set_ignore_time_scale(true)
	#tween.set_trans(Tween.TRANS_QUINT)
	#tween.set_ease(Tween.EASE_OUT)
	tween2.tween_property(target, "offset_transform_scale", Vector2(1.1, 1.1), 0.2)
	tween2.parallel().tween_property(target, "offset_transform_rotation", 0.3 * random, 0.1)
	tween2.parallel().tween_property(target, "offset_transform_rotation", 0.0, 0.1).set_delay(0.1)
	print("er")
	for i in range(3):
		if in_animation == false:
			var quest_slot = grid_container.get_child(i)
			var current_pos = quest_slot.offset_transform_position
			if tween : tween.kill()
			tween = create_tween().set_parallel(true)
			tween.tween_property(quest_slot,"offset_transform_position" ,current_pos + Vector2(0,-5 * i - 5), 0.1)
			quest_slot.z_index = -i
			await tween.finished


func _on_mouse_exited() -> void:
	tween2 = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween2.tween_property(self, "offset_transform_scale", Vector2(1, 1), 0.2)
	if in_animation == false:
		for i in range(3):
			in_animation = true
			var quest_slot = grid_container.get_child(i)
			if tween : tween.kill()
			tween = create_tween()
			tween.tween_property(quest_slot,"offset_transform_position" ,-quest_slot.Vposition + $"../..".position + Vector2(-3,-2.5) + Vposition, 0.1)
			await tween.finished
			if i == 2:
				in_animation = false
