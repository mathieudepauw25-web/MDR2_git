extends CanvasLayer

var viewControle = false
var tween : Tween
@onready var fullscreen_button: CheckButton = $CheckButton
@onready var h_slider_music: HSlider = $HSlider_music
@onready var h_slider_sound: HSlider = $HSlider_sound
@onready var controle: Button = $Controle
@onready var option_button_lang: OptionButton = $OptionButton_lang
var time_animation = 0.05

func _ready() -> void:
	$Controle.grab_focus()
	fullscreen_button.offset_transform_position = Vector2(-220,0)
	h_slider_music.offset_transform_position = Vector2(-380,0)
	h_slider_sound.offset_transform_position = Vector2(-380,0)
	controle.offset_transform_position = Vector2(200,0)
	option_button_lang.offset_transform_position = Vector2(0,-50)
	
	tween = create_tween()
	tween.tween_property(controle, "offset_transform_position", Vector2(-5,0), time_animation)
	tween.tween_property(controle, "offset_transform_position", Vector2(0,0), time_animation)
	tween.tween_property(h_slider_music, "offset_transform_position", Vector2(5,0), time_animation)
	tween.tween_property(h_slider_music, "offset_transform_position", Vector2(0,0), time_animation)
	tween.tween_property(h_slider_sound, "offset_transform_position", Vector2(5,0),time_animation)
	tween.tween_property(h_slider_sound, "offset_transform_position", Vector2(0,0), time_animation)
	tween.tween_property(fullscreen_button, "offset_transform_position", Vector2(5,0), time_animation)
	tween.tween_property(fullscreen_button, "offset_transform_position", Vector2(0,0), time_animation)
	tween.tween_property(option_button_lang, "offset_transform_position", Vector2(0,5), time_animation)
	tween.tween_property(option_button_lang, "offset_transform_position", Vector2(0,0), time_animation)
	
	
	$HSlider_music.value = GAMES.game_data.option_music
	$HSlider_sound.value = GAMES.game_data.option_sound

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_on_back_pressed()
	if visible == true:
		if event.is_action_pressed("move_left"): $SFX / UI_menu_up_down.play(0.02)
		if event.is_action_pressed("move_right"): $SFX / UI_menu_up_down.play(0.02)

func _on_back_pressed() -> void:
	if viewControle == false:
		EVENTS.emit_signal("change_to_main_menu")
		get_parent().get_child(4).find_child("CanvasLayer").visible = true
		get_parent().get_child(4).find_child("CanvasLayer").find_child("MenuControl").find_child("Controls").grab_focus()
		queue_free()
	else :
		$Controle.grab_focus()
		viewControle = false


func _on_controle_pressed() -> void:
	$".".queue_free()
	var Controles = preload("res://Larchet/Menus/ControlsPage/Scenes/Controls.tscn")
	var instControles = Controles.instantiate()
	get_parent().add_child(instControles)

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
	#%UI_toggle.play()
	EVENTS.emit_signal("save")


func _on_option_button_lang_item_selected(index: int) -> void :
	GAMES.game_data.option_langue = index
	$OptionButton_lang.selected = GAMES.game_data.option_langue
	EVENTS.emit_signal("save")
