extends Node2D

var grid_size: int = 16 

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	var camera = get_viewport().get_camera_2d()
	if not camera: return
	var line_color = Color(1.0, 1.0, 1.0, 0.2)
	var viewport_size = get_viewport_rect().size / camera.zoom
	var start_pos = camera.global_position - (viewport_size / 2.0)
	var end_pos = camera.global_position + (viewport_size / 2.0)
	var start_x = floor(start_pos.x / grid_size) * grid_size
	var start_y = floor(start_pos.y / grid_size) * grid_size
	var x = start_x
	while x <= end_pos.x:
		draw_line(Vector2(x, start_pos.y), Vector2(x, end_pos.y), line_color)
		x += grid_size
	var y = start_y
	while y <= end_pos.y:
		draw_line(Vector2(start_pos.x, y), Vector2(end_pos.x, y), line_color)
		y += grid_size
