extends Button

@export var TextEN: String
@export var TextFR: String
@export var asFontSize = false
@export var EnScale = 26
@export var FrScale = 26
@export var Basescale: = Vector2(1,1)
@export var augmentation: = Vector2(1.5, 1.5)
@export var move = true



func _ready() -> void :
	offset_transform_enabled = true
	connect("visibility_changed", _on_visibility_changed)
	EVENTS.connect("save", _on_visibility_changed)
	_on_visibility_changed()

func _on_visibility_changed() -> void :
	match GAMES.game_data.option_langue:
		0:
			text = TextEN
			if asFontSize == true:
				add_theme_font_size_override("font_size", EnScale)
		1:
			text = TextFR
			if asFontSize == true:
				add_theme_font_size_override("font_size", FrScale)

var tween: Tween
func _on_focus_entered() -> void:
	z_index = 2
	tween = create_tween()
	var target = self
	tween.set_ignore_time_scale(true)
	tween.set_trans(Tween.TRANS_QUINT)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(target, "offset_transform_scale", Basescale * augmentation, 0.2)
	if move == true:
		tween.parallel().tween_property(target, "offset_transform_rotation", 0.1, 0.2)
		tween.set_loops()
		tween.set_trans(Tween.TRANS_SINE)
		tween.set_ease(Tween.EASE_OUT)
		tween.tween_property(target, "offset_transform_rotation", -0.1, 2)
		tween.tween_property(target, "offset_transform_rotation", 0.1, 2)


func _on_focus_exited() -> void:
	if tween: tween.kill()
	
	z_index = 0
	tween = create_tween()
	tween.set_ignore_time_scale(true)
	var target = self
	tween.tween_property(target, "offset_transform_scale", Basescale, 0.2)
	tween.parallel().tween_property(target, "offset_transform_rotation", 0.0, 0.2)


func _on_mouse_entered() -> void:
	grab_focus()
