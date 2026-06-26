extends HBoxContainer
class_name Container_start_count


func _ready() -> void :
    EVENTS.connect("arrival", _on_EVENTS_arrival)
    EVENTS.connect("options", _on_EVENTS_options)
    EVENTS.connect("superdash_run", _on_EVENTS_superdash_run)

    visible = GAMES.game_data.option7

func _on_EVENTS_arrival() -> void :
    visible = GAMES.superdash_run

func _on_EVENTS_options(index_option: int, state: bool) -> void :
    if index_option == 7:
        EVENTS.emit_signal("save")
        visible = state

func _on_EVENTS_superdash_run() -> void :
    visible = true
