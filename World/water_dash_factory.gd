extends Node
class_name WaterDashFactory

var WaterDash_scene = preload("res://World/WaterDash/WaterDash.tscn")

func _ready() -> void :
	EVENTS.connect("waterDash", _on_EVENTS_waterDash)

func _on_EVENTS_waterDash(v_global_position: Vector2, v_direction: Vector2):
	var inst_waterDash = WaterDash_scene.instantiate()

	inst_waterDash.set_position(v_global_position)
	if v_direction == Vector2.LEFT: inst_waterDash.dash_left = true

	owner.call_deferred("add_child", inst_waterDash)
