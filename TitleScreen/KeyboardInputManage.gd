extends TextureRect

@export var textureInputEN: Texture
@export var textureInputFR: Texture

func _ready() -> void :
    connect("visibility_changed", _on_visibility_changed)


func _on_visibility_changed() -> void :
    match GAMES.game_data.option_langue:
        0:
            texture = textureInputEN
        1:
            texture = textureInputFR
