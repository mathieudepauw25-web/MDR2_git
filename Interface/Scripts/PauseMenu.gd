extends Control
class_name PauseMenu

@onready var button_focus: Button = %Restart
@onready var node_top_black_bar: ColorRect = %TopBlackBar
@onready var node_left_black_bar: ColorRect = %LeftBlackBar
@onready var node_botom_black_bar: ColorRect = %BotomBlackBar

@onready var node_check_box_timer: CheckBox = %CheckBox_Timer
@onready var node_check_box_best_timer: CheckBox = %CheckBox_BestTimer
@onready var node_check_box_nb_actions: CheckBox = %CheckBox_NbActions
@onready var node_check_box_nb_pok: CheckBox = %CheckBox_NbPok
@onready var node_check_box_nb_fall: CheckBox = %CheckBox_NbFall
@onready var node_check_box_inputs: CheckBox = %CheckBox_Inputs
@onready var node_check_box_stars: CheckBox = %CheckBox_Stars

@onready var slider_music: HSlider = $Panel_slider / HSlider_music
@onready var slider_sound: HSlider = $Panel_slider / HSlider_sound

@onready var ui_menu_up_down: AudioStreamPlayer = $SFX / UI_menu_up_down
@onready var ui_menu_click: AudioStreamPlayer = $SFX / UI_menu_click
@onready var ui_paused: AudioStreamPlayer = $SFX / UI_paused


var arrival = false
var paused: bool = false

func _ready() -> void :
	EVENTS.connect("arrival", _on_EVENTS_arrival)
	EVENTS.connect("paused", _on_paused)
	node_check_box_timer.button_pressed = GAMES.game_data.option1
	node_check_box_best_timer.button_pressed = GAMES.game_data.option2
	node_check_box_nb_actions.button_pressed = GAMES.game_data.option3
	node_check_box_nb_pok.button_pressed = GAMES.game_data.option4
	node_check_box_nb_fall.button_pressed = GAMES.game_data.option5
	node_check_box_inputs.button_pressed = GAMES.game_data.option6
	node_check_box_stars.button_pressed = GAMES.game_data.option7
	slider_music.value = GAMES.game_data.option_music
	slider_sound.value = GAMES.game_data.option_sound
	if GAMES.all_star_unlock:
		$Panel_superdash.visible = true

func _process(_delta: float) -> void :
	if arrival == false:
		if Input.is_action_just_pressed("pause"):
			pauseMenu()
		if Input.is_action_just_pressed("escape"):
			pauseMenu()



func _input(event: InputEvent) -> void :
	if event.is_action_pressed("shortcut_restart"): _on_restart_pressed()
	if paused:
		if event.is_action_pressed("move_down"): ui_menu_up_down.play(0.02)
		if event.is_action_pressed("move_up"): ui_menu_up_down.play(0.02)
		if event.is_action_pressed("move_left"): ui_menu_up_down.play(0.02)
		if event.is_action_pressed("move_right"): ui_menu_up_down.play(0.02)
		if event.is_action_pressed("ui_accept"): ui_menu_click.play()
		if event.is_action_released("dash_right"): _on_resume_pressed()

func pauseMenu() -> void :
	if paused:
		hide()
		Engine.time_scale = 1
		ui_paused.pitch_scale = 1.4
		ui_paused.play()
	else:
		show()
		Engine.time_scale = 0
		button_focus.grab_focus()
		ui_paused.pitch_scale = 0.8
		ui_paused.play()
		$Panel_fullscreen / CheckButton.button_pressed = GAMES.game_data.option_fullscreen
		$Panel_superdash / CheckButton.button_pressed = GAMES.game_data.option_superdash
	paused = !paused

func _on_quit_pressed() -> void :
	get_tree().quit()


func _on_restart_pressed() -> void :
	get_tree().reload_current_scene()
	Engine.time_scale = 1


func _on_resume_pressed() -> void :
	pauseMenu()

func _on_title_screen_pressed() -> void :
	get_tree().change_scene_to_file("res://TitleScreen/TitleScreen.tscn")



func _on_check_box_timer_toggled(toggled_on: bool) -> void :
	GAMES.game_data.option1 = toggled_on
	EVENTS.emit_signal("options", 1, toggled_on)


func _on_check_box_best_timer_toggled(toggled_on: bool) -> void :
	GAMES.game_data.option2 = toggled_on
	EVENTS.emit_signal("options", 2, toggled_on)


func _on_check_box_nb_actions_toggled(toggled_on: bool) -> void :
	GAMES.game_data.option3 = toggled_on
	EVENTS.emit_signal("options", 3, toggled_on)


func _on_check_box_nb_pok_toggled(toggled_on: bool) -> void :
	GAMES.game_data.option4 = toggled_on
	EVENTS.emit_signal("options", 4, toggled_on)


func _on_check_box_nb_fall_toggled(toggled_on: bool) -> void :
	GAMES.game_data.option5 = toggled_on
	EVENTS.emit_signal("options", 5, toggled_on)


func _on_check_box_inputs_toggled(toggled_on: bool) -> void :
	GAMES.game_data.option6 = toggled_on
	EVENTS.emit_signal("options", 6, toggled_on)


func _on_check_box_stars_toggled(toggled_on: bool) -> void :
	GAMES.game_data.option7 = toggled_on
	EVENTS.emit_signal("options", 7, toggled_on)



func _on_slider_music_value_changed(value: float) -> void :
	if value == -21: value = -999
	AudioServer.set_bus_volume_db(1, value)
	GAMES.game_data.option_music = value


func _on_slider_sound_value_changed(value: float) -> void :
	if value == -21: value = -999
	AudioServer.set_bus_volume_db(2, value)
	GAMES.game_data.option_sound = value
	$Audio_test_sound.pitch_scale = randf_range(2, 3)
	$Audio_test_sound.play()


func _on_EVENTS_arrival() -> void :
	arrival = true


func _on_check_button_toggled(toggled_on: bool) -> void :
	GAMES.game_data.option_fullscreen = toggled_on
	var window_mode = DisplayServer.WINDOW_MODE_WINDOWED
	if toggled_on: window_mode = DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN
	DisplayServer.window_set_mode(window_mode)
	$SFX / UI_toggle.play()
	EVENTS.emit_signal("save")


func _on_paused() -> void :
	paused = false
	pauseMenu()


func _on_check_buttonSD_toggled(toggled_on: bool) -> void :
	GAMES.game_data.option_superdash = toggled_on
	$SFX / UI_toggle.play()
	EVENTS.emit_signal("save")
