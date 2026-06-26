extends Button

@export var TextEN: String
@export var TextFR: String

func _ready() -> void :
	connect("visibility_changed", _on_visibility_changed)
	EVENTS.connect("save", _on_visibility_changed)
	_on_visibility_changed()


func _on_visibility_changed() -> void :
	match GAMES.game_data.option_langue:
		0:
			text = TextEN
		1:
			text = TextFR
