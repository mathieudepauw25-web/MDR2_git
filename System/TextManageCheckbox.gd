extends Button

@export var TextEN: String
@export var TextFR: String

func _ready() -> void :
	offset_transform_enabled = true
	connect("visibility_changed", _on_visibility_changed)
	EVENTS.connect("save", _on_visibility_changed)


func _on_visibility_changed() -> void :
	match GAMES.game_data.option_langue:
		0:
			text = TextEN
		1:
			text = TextFR

var tween: Tween
func _on_focus_entered() -> void:
	print("true")
	z_index = 2
	tween = create_tween()
	tween.set_ignore_time_scale(true)
	tween.set_loops()
	tween.tween_property(self, "offset_transform_scale", Vector2(1.3, 1.3) , 0.2)
	tween.parallel().tween_property(self, "offset_transform_position_ratio", Vector2(0.02, 0) , 2)
	tween.tween_property(self, "offset_transform_position_ratio", Vector2(-0.02, 0), 2)


func _on_focus_exited() -> void:
	z_index = 0
	tween.kill()
	tween = create_tween()
	tween.set_ignore_time_scale(true)
	tween.tween_property(self, "offset_transform_scale", Vector2(1, 1) , 0.1)
	tween.parallel().tween_property(self, "offset_transform_position_ratio", Vector2(0, 0) , 0.5)
