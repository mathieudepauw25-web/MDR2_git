extends TextureRect

@onready var move: Sprite2D = $move
@onready var dash: Sprite2D = $dash
@onready var rush: Sprite2D = $rush
@export var wait: = 0.5
var tween: Tween
var mdrLogoPos = Vector2(-631.045, -342.8)
var AnimationStoped = false

signal logoAnimationFini

var Bdashpos
var Brushpos 
var Bmovepos
func _ready() -> void:
	Bmovepos = move.position
	Bdashpos = dash.position
	Brushpos= rush.position
	if AnimationStoped == false:
		tween = create_tween()
		tween.tween_property(move, "position", Bmovepos * Vector2(30,0), 0)
		tween.tween_property(dash, "position", Bdashpos * Vector2(-30,0), 0)
		tween.tween_property(rush, "position", Brushpos * Vector2(30,0), 0)
		await create_tween().tween_interval(wait).finished
	if AnimationStoped == false:
		tween = create_tween()
		tween.tween_property(move, "position", Bmovepos + Vector2(-500,0), 0.3)
		tween.tween_property(move, "position", Bmovepos, 0.1)
		tween.tween_property(self, "offset_transform_scale", Vector2(1.1,1.1), 0.07)
		tween.tween_property(self, "offset_transform_scale", Vector2(1,1), 0.07)
		await create_tween().tween_interval(wait).finished
	if AnimationStoped == false:
		tween = create_tween()
		tween.tween_property(dash, "position", Bdashpos + Vector2(500,0), 0.3)
		tween.tween_property(dash, "position", Bdashpos, 0.1)
		tween.tween_property(self, "offset_transform_scale", Vector2(1.1,1.1), 0.07)
		tween.tween_property(self, "offset_transform_scale", Vector2(1,1), 00.07)
		await create_tween().tween_interval(wait).finished
	if AnimationStoped == false:
		tween = create_tween()
		tween.tween_property(rush, "position", Brushpos + Vector2(-500,0), 0.3)
		tween.tween_property(rush, "position", Brushpos, 0.1)
		tween.tween_property(self, "offset_transform_scale", Vector2(1.1,1.1), 0.07)
		tween.tween_property(self, "offset_transform_scale", Vector2(1,1), 0.07)
	########
	if AnimationStoped == false:
		tween.tween_property(self, "position", mdrLogoPos, 0.1)
		tween.parallel().tween_property(self, "scale", Vector2(0.165,0.165), 0.1)
		tween.tween_callback(logoAnimationFini.emit)
		
func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("CancelAnimation") and AnimationStoped == false:
		Stop_Animation()

func Stop_Animation():
		print("stooop")
		logoAnimationFini.emit()
		AnimationStoped = true
		tween.kill()
		tween = create_tween()
		tween.tween_property(move, "position", Bmovepos, 0)
		tween.tween_property(dash, "position", Bdashpos, 0)
		tween.tween_property(rush, "position", Brushpos, 0)
		tween.tween_property(self, "position", mdrLogoPos, 0)
		tween.parallel().tween_property(self, "scale", Vector2(0.165,0.165), 0)
		
