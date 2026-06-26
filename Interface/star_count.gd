extends Control
class_name StarCount

@export var secret_data: Resource


@export var color_free: Color

@onready var node_texture_rect: TextureRect = %TextureRect

func _ready() -> void :
    EVENTS.connect("collect_start", _on_EVENTS_collect_star)
    EVENTS.connect("update_star_data", _on_EVENTS_update_star_data)
    EVENTS.connect("superdash_run", _on_EVENTS_superdash_run)
    EVENTS.connect("arrival", _on_EVENTS_arrival)
    modulate = color_free
    check_already_collected()

func check_already_collected() -> void :
    match secret_data.secret_index:
        1:
            if GAMES.game_data.star1: update_visuel(true)
        2:
            if GAMES.game_data.star2: update_visuel(true)
        3:
            if GAMES.game_data.star3: update_visuel(true)
        4:
            if GAMES.game_data.star4: update_visuel(true)
        5:
            if GAMES.game_data.star5: update_visuel(true)
        6:
            if GAMES.game_data.star6: update_visuel(true)

func _on_EVENTS_collect_star(v_index_star) -> void :
    print("enter on_EVENTS_collect_star with index : " + str(v_index_star))
    if v_index_star == secret_data.secret_index: update_visuel()
    match v_index_star:
        1: GAMES.game_data.star1 = true
        2: GAMES.game_data.star2 = true
        3: GAMES.game_data.star3 = true
        4: GAMES.game_data.star4 = true
        5: GAMES.game_data.star5 = true
        6: GAMES.game_data.star6 = true
    EVENTS.emit_signal("save")

func _on_EVENTS_update_star_data() -> void :
    match secret_data.secret_index:
        1: if GAMES.game_data.star1: update_visuel()
        2: if GAMES.game_data.star2: update_visuel()
        3: if GAMES.game_data.star3: update_visuel()
        4: if GAMES.game_data.star4: update_visuel()
        5: if GAMES.game_data.star5: update_visuel()
        6: if GAMES.game_data.star6: update_visuel()

func update_visuel(_already_colect: bool = false) -> void :
    collect()
    modulate = secret_data.secret_color_modulate
    if _already_colect:
        modulate.a8 = 120

func collect() -> void :
    modulate = secret_data.secret_color_modulate
    $grab_star.play()

    scale = Vector2(2.0, 2.0)
    var tween = create_tween()
    tween.tween_property(self, "scale", Vector2(1.0, 1.0), 1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)

func _on_EVENTS_superdash_run() -> void :
    var timing: float = 0.1 * secret_data.secret_index
    $Timer.start(timing)

func _on_timer_timeout() -> void :
    $AnimationPlayer.play("superdash_run")

func _on_EVENTS_arrival() -> void :
    if GAMES.superdash_run:
        scale = scale * 2
