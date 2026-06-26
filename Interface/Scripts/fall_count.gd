extends Control
class_name FallCount

@onready var node_label: Label = %Label
var nb_fall: int = 0


func _ready() -> void :
    EVENTS.connect("player_fall", on_EVENTS_player_fall)
    EVENTS.connect("arrival", _on_EVENTS_arrival)
    EVENTS.connect("options", _on_EVENTS_options)

    visible = GAMES.game_data.option5

func on_EVENTS_player_fall() -> void :
    nb_fall += 1
    node_label.text = str(nb_fall)

func _on_EVENTS_arrival() -> void :
    visible = false


func _on_EVENTS_options(index_option: int, state: bool) -> void :
    if index_option == 5:
        EVENTS.emit_signal("save")
        visible = state
