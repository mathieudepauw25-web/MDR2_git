extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#for i in range(get_child_count()):
		#get_child(i).visible = false
	visible = false


		

var tween : Tween
func _on_md_rlogo_logo_animation_fini() -> void:
	$"../BlackScreen".visible = false
	visible = true
	
	#for i in range(get_child_count()):
		#if i != 1 :
			#if i != 5 :
				#var BasePos = get_child(i).position
				#get_child(i).visible = true
				#get_child(i).position = Vector2(77.31,-68.82)
				#tween = create_tween()
				#tween.tween_interval(i * 0.05)
				#tween.tween_property(get_child(i), "position", Vector2(randi_range(-30, 150),randi_range(30, -150)), 0.3)
				#tween.tween_interval(0.5)
				#tween.tween_property(get_child(i), "position", Vector2(randi_range(-30, 150),randi_range(30, -150)), 0.3)
				#tween.tween_interval(0.5)
				#tween.tween_property(get_child(i), "position", Vector2(randi_range(-30, 150),randi_range(30, -150)), 0.2)
				#tween.tween_interval(0.2)
				#tween.tween_property(get_child(i), "position", BasePos, 0.1)


	#for i in range(get_child_count()):
		#get_child(i).offset_transform_position = Vector2(999,0)
	
	#for i in range(get_child_count()):
		#var scale = get_child(i).offset_transform_scale
		#var tween = create_tween()
		#tween.tween_property(get_child(i), "offset_transform_position", Vector2(-50.0, 0.0), 0.3)
		#tween.tween_property(get_child(i), "offset_transform_position", Vector2(0.0, 0.0), 0.1)
		#tween.parallel().tween_property(get_child(i), "offset_transform_scale", get_child(i).offset_transform_scale* Vector2(1.3, 1.3), 0.1)
		#tween.tween_property(get_child(i), "offset_transform_scale", scale, 0.1)
		#await get_tree().create_timer(0.2).timeout
	
	%Start.grab_focus()
