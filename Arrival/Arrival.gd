extends Area2D
class_name Arrival

var arrival: = false
var arrivalScreen: PackedScene = preload("res://Interface/ArrivalScreen.tscn")


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
    owner.add_child(arrival_screen)
