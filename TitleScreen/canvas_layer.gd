extends CanvasLayer

var position_pricipale = offset

#var time_screen_shake := 5
#var force_screen_shake := 0.3


func shake_ui(time_screen_shake, force_screen_shake):
	print("shake")
	var tween = create_tween()
	
	for i in range(time_screen_shake):
		var shake_offset = Vector2(randf_range(-force_screen_shake, force_screen_shake), randf_range(-force_screen_shake, force_screen_shake))
		tween.tween_property(self, "offset", shake_offset + position_pricipale, 0.03)
	
	tween.tween_property(self, "offset", position_pricipale, 0.05)
