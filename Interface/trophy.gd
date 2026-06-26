extends Control
class_name Trophy

@onready var node_label: Label = %Label
@onready var node_sprite: TextureRect = %Sprite

@export var index_challenge: int = 0

func _ready() -> void :
    EVENTS.connect("save", _on_EVENTS_save)
    node_label.modulate = Color(0.5, 1, 0.5, 0.4)
    updateText()
    check_unlock()

func check_unlock() -> void :
    match index_challenge:
        1: if GAMES.game_data.challenge1: unlock()
        2: if GAMES.game_data.challenge2: unlock()
        3: if GAMES.game_data.challenge3: unlock()
        4: if GAMES.game_data.challenge4: unlock()
        5: if GAMES.game_data.challenge5: unlock()
        6: if GAMES.game_data.challenge6: unlock()

func unlock() -> void :
    node_sprite.modulate = Color(1, 1, 1, 1)
    node_label.modulate = Color(1, 1, 1, 1)

func updateText() -> void :
    match index_challenge:
        1: node_label.text = "07:00"
        2: node_label.text = "03:30"
        3: node_label.text = "02:00"
        4:
            node_label.text = "NO DASH"
            if GAMES.game_data.option_langue == 1:
                node_label.text = "0 DASH"
        5:
            node_label.text = "NO WALL"
            if GAMES.game_data.option_langue == 1:
                node_label.text = "0 MUR"
        6:
            node_label.text = "NO FALL"
            if GAMES.game_data.option_langue == 1:
                node_label.text = "0 CHUTE"

func _on_EVENTS_save() -> void :
    updateText()
