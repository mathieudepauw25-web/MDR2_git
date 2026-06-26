extends Area2D
class_name Hidden

@onready var node_sprite_2d: Sprite2D = %Sprite2D



func _ready() -> void :
	EVENTS.connect("hidden_tiles", _on_EVENTS_hidden_tiles)
	node_sprite_2d.scale = Vector2.ZERO

func pop() -> void :
	EVENTS.emit_signal("create_floor_tile", global_position)
	var tween = create_tween()
	tween.tween_property(node_sprite_2d, "scale", Vector2.ONE, 0.25).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)

func depop() -> void :
	EVENTS.emit_signal("erase_floor_tile", global_position)
	var tween = create_tween()
	tween.tween_property(node_sprite_2d, "scale", Vector2.ZERO, 0.25).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BOUNCE)

func _on_area_entered(area: Area2D) -> void :
	if area is Player:
		pop()

func _on_area_exited(area: Area2D) -> void :
	if area is Player:
		depop()

func _on_EVENTS_hidden_tiles(reveal: = false) -> void :
	if reveal: pop()
	else: depop()
