extends AudioStreamPlayer
class_name BGM

@export var superdash: bool = false

func _ready() -> void :
	EVENTS.connect("player_move", _on_EVENTS_player_move)
	EVENTS.connect("player_dash", _on_EVENTS_player_move)
	EVENTS.connect("player_pok", _on_EVENTS_player_pok)
	EVENTS.connect("player_fall", _on_EVENTS_player_fall)
	EVENTS.connect("player_inaction", _on_EVENTS_player_inaction)
	EVENTS.connect("arrival", _on_EVENTS_arrival)
	EVENTS.connect("superdash_run", _on_EVENTS_superdash_run)
	music_low()
	if superdash: stop()


func music_full() -> void :
	stream.set_sync_stream_volume(0, -999)
	stream.set_sync_stream_volume(1, 0)
	AudioServer.set_bus_effect_enabled(1, 0, false)


func music_low() -> void :
	stream.set_sync_stream_volume(0, -3)
	stream.set_sync_stream_volume(1, -999)
	AudioServer.set_bus_effect_enabled(1, 0, true)

func _on_EVENTS_player_move() -> void :
	music_full()

func _on_EVENTS_player_dash() -> void :
	music_full()

func _on_EVENTS_player_pok() -> void :
	music_low()

func _on_EVENTS_player_fall() -> void :
	music_low()

func _on_EVENTS_player_inaction() -> void :
	music_low()

func _on_EVENTS_arrival() -> void :
	stop()

func _on_EVENTS_superdash_run() -> void :
	if superdash:
		if !is_playing(): play()
	else: stop()
