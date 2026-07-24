extends TextureRect


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	offset_transform_position = Vector2(-999, 0)
	var tween = create_tween()
	tween.tween_property(self, "offset_transform_position", Vector2(50,0), 0.3)
	tween.tween_property(self, "offset_transform_position", Vector2(0,0), 0.1)
	var tween2 = create_tween()
	tween2.set_trans(Tween.TRANS_SINE)
	tween2.set_ease(Tween.EASE_OUT)
	tween2.set_loops()
	tween2.tween_property(self, "offset_transform_rotation", -0.01, 0.5)
	tween2.tween_property(self, "offset_transform_rotation", 0.01, 0.5)
	
