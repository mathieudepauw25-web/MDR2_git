extends Camera2D
class_name Camera

@export var randomStrength: float = 6.0
@export var shakeFade: float = 20.0

var rng = RandomNumberGenerator.new()

var shake_strength: float = 0.0


func _ready() -> void :
    EVENTS.connect("shake_camera", on_EVENTS_shake_camera)
    EVENTS.connect("arrival", _on_EVENTS_arrival)

func _process(delta: float) -> void :
    if shake_strength > 0.1:
        shake_strength = lerpf(shake_strength, 0, shakeFade * delta)
        offset = random_offset()
    if Engine.time_scale == 0:
        shake_strength = 0

func dezoom_dash(value_dezoom: float = 0.95, value_speed_reset: float = 0.5) -> void :
    var tween = create_tween()
    tween.tween_property(self, "zoom", Vector2(value_dezoom, value_dezoom), 0.05).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_LINEAR)
    tween.tween_property(self, "zoom", Vector2(1.0, 1.0), value_speed_reset).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BACK)

func apply_shake() -> void :
    shake_strength = randomStrength

func random_offset() -> Vector2:
    var random_pick: float = rng.randf_range( - shake_strength, shake_strength)
    return Vector2(random_pick, random_pick)

func on_EVENTS_shake_camera() -> void :
    apply_shake()

func _on_EVENTS_arrival() -> void :
    var tween = create_tween()
    tween.tween_property(self, "zoom", Vector2(2.0, 2.0), 1).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_ELASTIC)
    tween.tween_property(self, "offset", Vector2(25.0, 0.0), 2).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BACK)
