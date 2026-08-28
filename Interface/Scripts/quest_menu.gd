extends CanvasLayer

@onready var item_list: GridContainer = $ScrollContainer/ItemList

var tween : Tween
func _ready() -> void:
	item_list.get_child(0).grab_focus()
	for i in range(item_list.get_child_count()):
		var node = item_list.get_child(i)
		node.offset_transform_scale = Vector2(0,0)
	for i in range(item_list.get_child_count()):
		var node = item_list.get_child(i)
		tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
		tween.tween_property(node, "offset_transform_scale", Vector2(1.1,1.1), 0.1)
		tween.tween_property(node, "offset_transform_scale", Vector2(1,1), 0.1)
		await get_tree().create_timer(0.1).timeout


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("escape") :
		for i in range(item_list.get_child_count()):
			if item_list.get_child(i).quest_show == true:
				break
			if i == item_list.get_child_count() - 1:
				EVENTS.emit_signal("change_to_main_menu")
				get_parent().get_child(5).find_child("CanvasLayer").visible = true
				get_parent().get_child(5).find_child("CanvasLayer").find_child("MenuControl").find_child("Quest").grab_focus()
				queue_free()
