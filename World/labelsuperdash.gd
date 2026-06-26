extends Label
class_name label_superdash

@export_multiline var text_arrival_EN: String
@export_multiline var text_arrival_FR: String

func _ready() -> void :
    visible = false
    EVENTS.connect("superdash_run", _on_EVENTS_superdash_run)
    EVENTS.connect("arrival", _on_EVENTS_arrival)


func _on_EVENTS_superdash_run() -> void :
    visible = true

func _on_EVENTS_arrival() -> void :
    horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    modulate.a8 = 255
    label_settings.outline_size = 1
    match GAMES.game_data.option_langue:
        0: text = text_arrival_EN
        1: text = text_arrival_FR
