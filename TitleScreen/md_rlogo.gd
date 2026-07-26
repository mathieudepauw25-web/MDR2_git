extends TextureRect

@onready var move: Sprite2D = $move
@onready var dash: Sprite2D = $dash
@onready var rush: Sprite2D = $rush
@export var wait: = 0.5
var tween: Tween
var mdrLogoPos = Vector2(-631.045, -342.8)

signal logoAnimationFini

func _ready() -> void:
	var Bmovepos = move.position
	var Bdashpos = dash.position
	var Brushpos = rush.position
	tween = create_tween()
	tween.tween_property(move, "position", Bmovepos * Vector2(30,0), 0)
	tween.tween_property(dash, "position", Bdashpos * Vector2(-30,0), 0)
	tween.tween_property(rush, "position", Brushpos * Vector2(30,0), 0)
	await create_tween().tween_interval(wait).finished
	tween = create_tween()
	tween.tween_property(move, "position", Bmovepos + Vector2(-500,0), 0.3)
	tween.tween_property(move, "position", Bmovepos, 0.1)
	tween.tween_property(self, "offset_transform_scale", Vector2(1.1,1.1), 0.07)
	tween.tween_property(self, "offset_transform_scale", Vector2(1,1), 0.07)
	await create_tween().tween_interval(wait).finished
	tween = create_tween()
	tween.tween_property(dash, "position", Bdashpos + Vector2(500,0), 0.3)
	tween.tween_property(dash, "position", Bdashpos, 0.1)
	tween.tween_property(self, "offset_transform_scale", Vector2(1.1,1.1), 0.07)
	tween.tween_property(self, "offset_transform_scale", Vector2(1,1), 00.07)
	await create_tween().tween_interval(wait).finished
	tween = create_tween()
	tween.tween_property(rush, "position", Brushpos + Vector2(-500,0), 0.3)
	tween.tween_property(rush, "position", Brushpos, 0.1)
	tween.tween_property(self, "offset_transform_scale", Vector2(1.1,1.1), 0.07)
	tween.tween_property(self, "offset_transform_scale", Vector2(1,1), 0.07)
	########
	tween.tween_property(self, "position", mdrLogoPos, 0.1)
	tween.parallel().tween_property(self, "scale", Vector2(0.165,0.165), 0.1)
	tween.tween_callback(logoAnimationFini.emit)
	#var tween2 = create_tween()
	#tween2.set_trans(Tween.TRANS_SINE)
	#tween2.set_ease(Tween.EASE_OUT)
	#tween2.set_loops()
	#tween2.tween_property(self, "offset_transform_rotation", -0.01, 0.5)
	#tween2.tween_property(self, "offset_transform_rotation", 0.01, 0.5)
	
