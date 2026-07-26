extends Button


@onready var panel_options_2: panelOptions = $"Panel_options2"

func _ready() -> void:
	pass



var tween: Tween
func _on_focus_entered() -> void:
	focus_neighbor_left = $"../MarginContainer/HBoxContainer/ColonneGauche".get_child(4).get_path()
	focus_neighbor_top = $"../MarginContainer/HBoxContainer/ColonneGauche".get_child(4).get_path()
	z_index = 2
	tween = create_tween()
	var target = self
	tween.set_trans(Tween.TRANS_QUINT)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(target, "offset_transform_scale", Vector2(1.1,1.1), 0.2)


func _on_focus_exited() -> void:
	if tween: tween.kill()
	
	z_index = 1
	tween = create_tween()
	var target = self
	tween.tween_property(target, "offset_transform_scale", Vector2(1.0,1.0), 0.2)
	tween.parallel().tween_property(target, "offset_transform_rotation", 0.0, 0.2)


func _on_pressed(forced_close: bool = false) -> void:
	panel_options_2.visible = !panel_options_2.visible
	if forced_close: panel_options_2.visible = false
	$texture_deploy_option.visible = panel_options_2.visible
