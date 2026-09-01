extends Control

@onready var Canvas_layer = $CanvasLayer
@onready var grid_container: GridContainer = $CanvasLayer/ScrollContainer/GridContainer
@onready var color_rect: ColorRect = $CanvasLayer/ColorRect
@onready var progress_bar: ProgressBar = $ProgressBar

@export var number_of_quest : int
@export var pack_name : String
@export var is_finished : bool
@export var animation : String
var quest_show := false

var tween : Tween
var in_animation = false

func _ready() -> void:
	
	Canvas_layer.visible = false
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
		#quest_slot.offset_transform_position = -quest_slot.position + $"../..".position + Vector2(-3,-2.5) + position
		quest_slot.offset_transform_position = Vector2(11, 34.5)

func verif_quest():
	progress_bar.max_value = grid_container.get_child_count()
	
	var count = 0
	print("le grid container contient: " + str(grid_container.get_child_count()))
	for i in range(grid_container.get_child_count()):
		var quest_slot = grid_container.get_child(i)
		if quest_slot.quest_finish == true:
			count += 1
	progress_bar.value = count
	print("nbr de quetes fini: " + str(count))


func _process(_delta: float) -> void:
	$ProgressBar/RichTextLabel.text = str(int(progress_bar.value)) + "/" + str(int(progress_bar.max_value))
	if Input.is_action_just_pressed("escape"):
		if quest_show == true:
			if tween : tween.kill()
			quest_show = false
			Canvas_layer.visible = false
			in_animation = false
			color_rect.visible = false
			self.grab_focus()
			reposition()

func _on_pressed() -> void:
	grid_container.get_child(0).grab_focus()
	quest_show = true
	in_animation = true
	color_rect.visible = true
	Canvas_layer.visible = true
	Canvas_layer.layer = 2
	for i in range(grid_container.get_child_count()):
		var quest_slot = grid_container.get_child(i)
		quest_slot.visible = false
		quest_slot.offset_transform_scale = Vector2(0,0)
		quest_slot.offset_transform_position = Vector2(0,0)
	for i in range(grid_container.get_child_count()):
		var quest_slot = grid_container.get_child(i)
		#var actual_offset_position = quest_slot.offset_transform_position
		quest_slot.visible = true
		tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
		#tween.tween_property(quest_slot,"offset_transform_position" , -actual_offset_position / 10 , 0.1)
		#tween.tween_property(quest_slot,"offset_transform_position" , Vector2(0,0), 0.05)
		tween.tween_property(quest_slot,"offset_transform_scale" , Vector2(1.1,1.1) , 0.1)
		tween.parallel().tween_property(quest_slot,"offset_transform_rotation" , 0.1 * [1 , -1].pick_random() , 0.1)
		tween.tween_property(quest_slot,"offset_transform_rotation" , 0 , 0.1)
		tween.parallel().tween_property(quest_slot,"offset_transform_scale" , Vector2(1,1) , 0.1)
		await get_tree().create_timer(0.05).timeout
		quest_slot.finish_anim()
		quest_slot.z_index = 0
		
	
var tween2 : Tween


func _on_focus_entered() -> void:
	var random =  [-1.0, 1.0].pick_random()
	z_index = 2
	tween2 = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	var target = self
	tween2.set_ignore_time_scale(true)
	tween2.tween_property(target, "offset_transform_scale", Vector2(1.1, 1.1), 0.2)
	tween2.parallel().tween_property(target, "offset_transform_rotation", 0.3 * random, 0.1)
	tween2.parallel().tween_property(target, "offset_transform_rotation", 0.0, 0.1).set_delay(0.1)


func _on_focus_exited() -> void:
	tween2 = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween2.tween_property(self, "offset_transform_scale", Vector2(1, 1), 0.2)


func _on_mouse_entered() -> void:
	grab_focus()
