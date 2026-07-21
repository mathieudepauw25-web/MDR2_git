extends Node2D
class_name InputVisuel

@onready var move_r: Sprite2D = %move_R
@onready var move_u: Sprite2D = %move_U
@onready var move_l: Sprite2D = %move_L
@onready var move_d: Sprite2D = %move_D
@onready var dash_r: Sprite2D = %dash_R
@onready var dash_u: Sprite2D = %dash_U
@onready var dash_l: Sprite2D = %dash_L
@onready var dash_d: Sprite2D = %dash_D

@export var color_show: Color
@export var color_hide: Color

func _ready() -> void :
	EVENTS.connect("options", _on_EVENTS_options)
	EVENTS.connect("arrival", _on_EVENTS_arrival)

	visible = GAMES.game_data.option6

func _process(_delta: float) -> void :
	hide_input(move_r)
	hide_input(move_u)
	hide_input(move_l)
	hide_input(move_d)

	hide_input(dash_r)
	hide_input(dash_u)
	hide_input(dash_l)
	hide_input(dash_d)

	if Input.is_action_pressed("move_right"): show_input(move_r)
	if Input.is_action_pressed("move_up"): show_input(move_u)
	if Input.is_action_pressed("move_left"): show_input(move_l)
	if Input.is_action_pressed("move_down"): show_input(move_d)

	if Input.is_action_pressed("dash_right"): show_input(dash_r)
	if Input.is_action_pressed("dash_up"): show_input(dash_u)
	if Input.is_action_pressed("dash_left"): show_input(dash_l)
	if Input.is_action_pressed("dash_down"): show_input(dash_d)

func show_input(sprite: Sprite2D) -> void :
	sprite.modulate = color_show

func hide_input(sprite: Sprite2D) -> void :
	sprite.modulate = color_hide

func _on_EVENTS_options(index_option: int, state: bool) -> void :
	if index_option == 6:
		EVENTS.emit_signal("save")
		visible = state

func _on_EVENTS_arrival() -> void :
	visible = false
