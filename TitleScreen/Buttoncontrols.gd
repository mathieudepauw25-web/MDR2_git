extends Button


var tween: Tween
func _on_focus_entered() -> void:
	z_index = 2
	tween = create_tween()
	var target = self
	tween.set_trans(Tween.TRANS_QUINT)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(target, "offset_transform_scale", Vector2(1.5,1.5), 0.2)
	tween.parallel().tween_property(target, "offset_transform_rotation", 0.2, 0.5)
	tween.set_loops()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(target, "offset_transform_rotation", 0.1, 2)
	tween.tween_property(target, "offset_transform_rotation", 0.2, 2)


func _on_focus_exited() -> void:
	if tween: tween.kill()
	
	z_index = 1
	tween = create_tween()
	var target = self
	tween.tween_property(target, "offset_transform_scale", Vector2(1.0,1.0), 0.2)
	tween.parallel().tween_property(target, "offset_transform_rotation", 0.0, 0.2)
