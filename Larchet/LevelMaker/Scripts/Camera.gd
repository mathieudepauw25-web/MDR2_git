extends Camera2D

var is_panning: bool = false
var zoom_min: float = 0.2
var zoom_max: float = 3.0
var zoom_speed: float = 0.1

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.is_echo():
		if event.keycode == KEY_0 or event.keycode == KEY_KP_0:
			global_position = Vector2.ZERO
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_MIDDLE:
			is_panning = event.pressed
		elif event.pressed:
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				apply_zoom(zoom_speed)
			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				apply_zoom(-zoom_speed)
	if event is InputEventMouseMotion:
		if is_panning:
			position -= event.relative / zoom
			return

func apply_zoom(amount: float) -> void:
	var current_zoom = zoom.x
	var new_zoom = clamp(current_zoom + amount, zoom_min, zoom_max)
	zoom = Vector2(new_zoom, new_zoom)
