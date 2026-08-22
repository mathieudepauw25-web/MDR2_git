extends Control

func _ready() -> void:
	visible = false
	tween = create_tween()
	tween.tween_property($Panel, "offset_transform_position_ratio", Vector2(0,20), 0)



var tween : Tween
func _on_md_rlogo_logo_animation_fini() -> void:
	$"../MDRlogo/CPUParticles2D".emitting = true
	$"../MDRlogo/CPUParticles2D2".emitting = true
	$"../MDRlogo/CPUParticles2D3".emitting = true
	$"../BlackScreen".visible = false
	tween = create_tween()
	visible = true
	tween.tween_property($Panel, "offset_transform_position_ratio", Vector2(0,2), 0.2)
	tween.tween_property($Panel, "offset_transform_position_ratio", Vector2(0,0), 0.1)
	tween.tween_callback(%Start.grab_focus)
	
