extends Button
class_name ControlSlot

@onready var label_action: Label = $Name
@onready var label_key: Label = $Button

var action_id: String = ""


func setup(p_action_id: String, p_action_name: String, p_current_key: String) -> void:
	action_id = p_action_id
	label_action.text = p_action_name
	label_key.text = p_current_key

func update_key_text(new_text: String) -> void:
	label_key.text = new_text



func _on_hover() -> void:
	$%Move.play()

var tween: Tween
func _on_focus_exited() -> void:
	if tween: tween.kill()
	
	z_index = 1
	tween = create_tween()
	tween.set_ignore_time_scale(true)
	var target = self
	tween.tween_property(target, "offset_transform_scale", Vector2(1.0,1.0), 0.2)
	tween.parallel().tween_property(target, "offset_transform_position_ratio",Vector2(0,0), 0.5)


func _on_focus_entered() -> void:
	z_index = 2
	tween = create_tween()
	var target = self
	tween.set_ignore_time_scale(true)
	tween.set_trans(Tween.TRANS_QUINT)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(target, "offset_transform_scale", Vector2(1.2,1.2), 0.2)
	tween.set_loops()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(target, "offset_transform_position_ratio", Vector2(0.02,0), 2)
	tween.tween_property(target, "offset_transform_position_ratio",Vector2(-0.02,0), 2)
