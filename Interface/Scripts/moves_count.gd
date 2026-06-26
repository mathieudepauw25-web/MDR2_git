extends Control
class_name MovesCount

@onready var node_label: Label = %Label
var nb_action: int = 0


func _ready() -> void :
    EVENTS.connect("player_move", on_EVENTS_player_action)
    EVENTS.connect("player_dash", on_EVENTS_player_action)
    EVENTS.connect("arrival", _on_EVENTS_arrival)
    EVENTS.connect("options", _on_EVENTS_options)

    visible = GAMES.game_data.option3

func on_EVENTS_player_action() -> void :
    nb_action += 1
    node_label.text = str(nb_action)

func _on_EVENTS_arrival() -> void :
    visible = false

func _on_EVENTS_options(index_option: int, state: bool) -> void :
    if index_option == 3:
        EVENTS.emit_signal("save")
        visible = state
