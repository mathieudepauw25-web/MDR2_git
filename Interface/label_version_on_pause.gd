extends Label
class_name label_version_on_pause

var game_version = str(ProjectSettings.get_setting("application/config/version"))
var save_version = str(GAMES.game_data.version)

func _ready() -> void :
    text = game_version

func _input(event: InputEvent) -> void :
    if event.is_action_pressed("dash_left"): text = str("*", save_version, "*")
    if event.is_action_released("dash_left"): text = game_version
