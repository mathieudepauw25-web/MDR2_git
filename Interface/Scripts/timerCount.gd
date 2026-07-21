extends Control
class_name TimerCount

@onready var node_label_min: Label = %Label_min
@onready var node_label_sec: Label = %Label_sec
@onready var node_label_msec: Label = %Label_msec

var time_spend: float = 0.0
var starting_signal: bool = false
var arrival: bool = false

func _ready() -> void :
	EVENTS.connect("starting", _on_EVENTS_starting)
	EVENTS.connect("arrival", _on_EVENTS_arrival)
	EVENTS.connect("options", _on_EVENTS_options)

	visible = GAMES.game_data.option1

func _process(delta: float) -> void :
	if starting_signal and !arrival:
		time_spend += delta
		node_label_min.text = get_string_timer_min()
		node_label_sec.text = get_string_timer_sec()
		node_label_msec.text = get_string_timer_msec()

func get_string_timer_min() -> String:
	var _min = time_spend / 60
	return "%2d :" % _min

func get_string_timer_sec() -> String:
	var sec = fmod(time_spend, 60)
	return "%02d :" % sec

func get_string_timer_msec() -> String:
	var msec = fmod(time_spend, 1) * 1000
	return "%02d" % msec

func _on_EVENTS_starting() -> void :
	starting_signal = true

func _on_EVENTS_arrival() -> void :
	visible = false
	arrival = true
	GAMES.game_data.run_time = time_spend
	GAMES.check_trophy_already_unlock()
	GAMES.update_best_time(time_spend)

	if GAMES.game_data.previous_best_time == GAMES.game_data.defaut_highscore:
		GAMES.game_data.option7 = true

	EVENTS.emit_signal("save")

func _on_EVENTS_options(index_option: int, state: bool) -> void :
	if index_option == 1:
		EVENTS.emit_signal("save")
		visible = state
