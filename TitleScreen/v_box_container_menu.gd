extends VBoxContainer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in range(get_child_count()):
		get_child(i).offset_transform_position = Vector2(999,0)
	
	for i in range(get_child_count()):
		var scale = get_child(i).offset_transform_scale
		var tween = create_tween()
		tween.tween_property(get_child(i), "offset_transform_position", Vector2(-50.0, 0.0), 0.3)
		tween.tween_property(get_child(i), "offset_transform_position", Vector2(0.0, 0.0), 0.1)
		tween.parallel().tween_property(get_child(i), "offset_transform_scale", get_child(i).offset_transform_scale* Vector2(2.0, 2.0), 0.1)
		tween.tween_property(get_child(i), "offset_transform_scale", scale, 0.1)
		await get_tree().create_timer(0.2).timeout
		
		
