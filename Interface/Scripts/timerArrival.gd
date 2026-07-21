extends Control
class_name TimerArrival

@onready var node_label_min: Label = %Label_min
@onready var node_label_sec: Label = %Label_sec
@onready var node_label_msec: Label = %Label_msec
@onready var node_timer_best: TimerBest = %TimerBest

@export var scale_up: = 3.0
@export var speed_scale_up: = 0.1
@export var speed_scale_down: = 0.3
@export var decal_y: = 10.0

var rng = RandomNumberGenerator.new()
@warning_ignore("shadowed_global_identifier")
var seed: = randi_range(0, 9999999999)
var fixe_min: = false
var fixe_sec: = false
var fixe_msec: = false

func _ready() -> void :
	rng.seed = seed
	node_timer_best.visible = false

func _process(_delta: float) -> void :
	if !fixe_min: node_label_min.text = get_string_timer_min()
	if !fixe_sec: node_label_sec.text = get_string_timer_sec()
	if !fixe_msec: node_label_msec.text = get_string_timer_msec()


func get_string_timer_min() -> String:
	var _min = rng.randi_range(0, 22)
	return "%2d :" % _min

func get_string_timer_sec() -> String:
	var sec = rng.randi_range(0, 59)
	return "%02d :" % sec

func get_string_timer_msec() -> String:
	var msec = rng.randi_range(0, 999)
	return "%02d" % msec


func _on_timer_min_timeout() -> void :
	fixe_min = true
	node_label_min.text = GAMES.get_run_time(1)
	$Score_scroll3.stop()
	$Drum.play()
	var tween = create_tween().set_parallel()
	tween.tween_property(node_label_min, "scale", Vector2(scale_up, scale_up), speed_scale_up).set_ease(tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property(node_label_min, "offset_bottom", decal_y, speed_scale_up).set_ease(tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)
	tween.set_parallel(false)
	tween.tween_property(node_label_min, "scale", Vector2(1.0, 1.0), speed_scale_down).set_ease(tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.set_parallel(true)
	tween.tween_property(node_label_min, "offset_bottom", 0, speed_scale_up).set_ease(tween.EASE_OUT).set_trans(Tween.TRANS_BACK)


func _on_timer_sec_timeout() -> void :
	fixe_sec = true
	node_label_sec.text = GAMES.get_run_time(2)
	$Score_scroll2.stop()
	$Drum.play()
	var tween = create_tween()
	tween.tween_property(node_label_sec, "scale", Vector2(scale_up, scale_up), speed_scale_up).set_ease(tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property(node_label_sec, "scale", Vector2(1.0, 1.0), speed_scale_down).set_ease(tween.EASE_IN_OUT).set_trans(Tween.TRANS_BACK)


func _on_timer_msec_timeout() -> void :
	fixe_msec = true
	node_label_msec.text = GAMES.get_run_time(3)
	$Score_scroll.stop()
	$Drum.play()
	var tween = create_tween()
	tween.tween_property(node_label_msec, "scale", Vector2(scale_up, scale_up), speed_scale_up).set_ease(tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property(node_label_msec, "scale", Vector2(1.0, 1.0), speed_scale_down).set_ease(tween.EASE_IN_OUT).set_trans(Tween.TRANS_BACK)
