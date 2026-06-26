extends Control
class_name panelOptions


func _ready() -> void :
	$Panel / HSlider_music.value = GAMES.game_data.option_music
	$Panel / HSlider_sound.value = GAMES.game_data.option_sound

func _input(event: InputEvent) -> void :
	if visible == true:
		if event.is_action_pressed("move_left"): $SFX / UI_menu_up_down.play(0.02)
		if event.is_action_pressed("move_right"): $SFX / UI_menu_up_down.play(0.02)
		if event.is_action_pressed("dash_right"): _on_check_box_pressed()
		if event.is_action_released("escape"): _on_check_box_pressed()

func _on_h_slider_music_value_changed(value: float) -> void :
	if value == -21: value = -999
	AudioServer.set_bus_volume_db(1, value)
	GAMES.game_data.option_music = value
	EVENTS.emit_signal("save")


func _on_h_slider_sound_value_changed(value: float) -> void :
	if value == -21: value = -999
	AudioServer.set_bus_volume_db(2, value)
	GAMES.game_data.option_sound = value
	$Audio_test_sound.pitch_scale = randf_range(2, 3)
	$Audio_test_sound.play()
	EVENTS.emit_signal("save")


func _on_check_button_toggled(toggled_on: bool) -> void :
	GAMES.game_data.option_fullscreen = toggled_on
	var window_mode = DisplayServer.WINDOW_MODE_WINDOWED
	if toggled_on: window_mode = DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN
	DisplayServer.window_set_mode(window_mode)
	%UI_toggle.play()
	EVENTS.emit_signal("save")


func _on_check_box_pressed() -> void :
	$SFX / UI_cancel.play()
	EVENTS.emit_signal("close_option")


func _on_visibility_changed() -> void :
	$Panel / CheckButton.button_pressed = GAMES.game_data.option_fullscreen
	$Panel / OptionButton_lang.selected = GAMES.game_data.option_langue


func _on_option_button_lang_item_selected(index: int) -> void :
	GAMES.game_data.option_langue = index
	$Panel / OptionButton_lang.selected = GAMES.game_data.option_langue
	EVENTS.emit_signal("save")
