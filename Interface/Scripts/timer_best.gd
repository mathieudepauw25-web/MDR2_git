extends Control
class_name TimerBest

@export var superdash_time: bool = false
@onready var node_best_label_min: Label = %best_Label_min
@onready var node_best_label_sec: Label = %best_Label_sec
@onready var node_best_label_msec: Label = %best_Label_msec

var global_time: float = 0.0

func _ready() -> void :
	EVENTS.connect("arrival", _on_EVENTS_arrival)
	EVENTS.connect("options", _on_EVENTS_options)
	EVENTS.connect("superdash_run", _on_EVENTS_superdash_run)

	visible = GAMES.game_data.option2

	compute_time()

func compute_time() -> void :
	global_time = GAMES.game_data.best_global_time
	if GAMES.superdash_run: superdash_time = true
	if superdash_time:
		global_time = GAMES.game_data.best_global_time_superdash

	var min = global_time / 60
	var sec = fmod(global_time, 60)
	var msec = fmod(global_time, 1) * 1000
	node_best_label_min.text = str("%2d :" % min)
	node_best_label_sec.text = str("%02d :" % sec)
	node_best_label_msec.text = str("%02d" % msec)

func update() -> void :
	global_time = GAMES.game_data.best_global_time
	if superdash_time:
		global_time = GAMES.game_data.best_global_time_superdash

func _on_EVENTS_arrival() -> void :
	visible = false

func _on_EVENTS_options(index_option: int, state: bool) -> void :
	if index_option == 2:
		EVENTS.emit_signal("save")
		visible = state

func _on_EVENTS_superdash_run() -> void :
	compute_time()
