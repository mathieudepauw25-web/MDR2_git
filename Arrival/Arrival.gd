extends Area2D
class_name Arrival

var arrival: = false
var arrivalScreen: PackedScene = preload("res://Interface/ArrivalScreen.tscn")

func _ready() -> void:
	if not area_entered.is_connected(_on_area_entered):
		area_entered.connect(_on_area_entered)
	add_to_group("Arrival")

func _on_area_entered(area: Area2D) -> void :
	if area is Player:
		if arrival == false:
			arrival = true
			GAMES.game_data.nb_wall_hit -= 1
			EVENTS.emit_signal("arrival")
			show_arrival_screen()
			area.move(Vector2.ZERO)

func show_arrival_screen() -> void :
	var arrival_screen = arrivalScreen.instantiate()
	arrival_screen.add_to_group("UI_Arrival")
	var current_scene = get_tree().current_scene
	if current_scene != null:
		current_scene.add_child(arrival_screen)
	else:
		add_child(arrival_screen)
