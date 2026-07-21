extends Camera2D
class_name Mapfree


@export var speed: = 2.0






func _process(_delta: float) -> void :
	if enabled:
		if Input.is_action_pressed("move_right"):
			camera_move(global_position + Vector2(speed / zoom.x, 0))
		if Input.is_action_pressed("move_up"):
			camera_move(global_position + Vector2(0, - speed / zoom.x))
		if Input.is_action_pressed("move_left"):
			camera_move(global_position + Vector2( - speed / zoom.x, 0))
		if Input.is_action_pressed("move_down"):
			camera_move(global_position + Vector2(0, speed / zoom.x))
		if Input.is_action_just_pressed("dash_up"):
			zoom = zoom * 2
			camera_zoom_clamp()
		if Input.is_action_just_pressed("dash_down"):
			zoom = zoom / 2
			camera_zoom_clamp()
		if Input.is_action_just_pressed("dash_left"):
			$"../World/Grid".visible = !$"../World/Grid".visible
		if Input.is_action_pressed("pause"):
			print(global_position)

func camera_move(new_position: Vector2) -> void :
	global_position = new_position
	global_position.x = clamp(global_position.x, 475, 2200)
	global_position.y = clamp(global_position.y, 460, 1192)

func camera_zoom_clamp() -> void :
	var clamp_min = 0.125
	var clamp_max = 2
	zoom.x = clamp(zoom.x, clamp_min, clamp_max)
	zoom.y = clamp(zoom.y, clamp_min, clamp_max)
