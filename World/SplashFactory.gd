extends Node
class_name SplashFactory

var splash_scene = preload("res://World/Splash.tscn")

func _ready() -> void :
	EVENTS.connect("splash", _on_EVENTS_splash)

func _on_EVENTS_splash(v_global_position: Vector2):
	var inst_splash = splash_scene.instantiate()

	inst_splash.set_position(v_global_position)
	owner.call_deferred("add_child", inst_splash)
