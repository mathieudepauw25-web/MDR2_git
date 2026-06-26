extends Control
class_name PokCount

@onready var node_label: Label = %Label
var nb_pok: int = 0


func _ready() -> void :
    EVENTS.connect("player_pok", on_EVENTS_player_pok)
    EVENTS.connect("arrival", _on_EVENTS_arrival)
    EVENTS.connect("options", _on_EVENTS_options)

    visible = GAMES.game_data.option4

func on_EVENTS_player_pok() -> void :
    nb_pok += 1
    node_label.text = str(nb_pok)

func _on_EVENTS_arrival() -> void :
    visible = false

func _on_EVENTS_options(index_option: int, state: bool) -> void :
    if index_option == 4:
        EVENTS.emit_signal("save")
        visible = state
