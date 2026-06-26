extends Control
class_name trophyResume

@onready var button_ok: Button = $CanvasLayer / MarginContainer / Panel / Button
@onready var panel: MarginContainer = $CanvasLayer / MarginContainer
@onready var gpu_particles_2d: GPUParticles2D = $CanvasLayer / GPUParticles2D
@onready var blur: ColorRect = $CanvasLayer / Blur
@onready var color_rect: ColorRect = $CanvasLayer / ColorRect

@onready var trophy_1: Trophy = $CanvasLayer / MarginContainer / Panel / HBoxContainer / Trophy
@onready var trophy_2: Trophy = $CanvasLayer / MarginContainer / Panel / HBoxContainer / Trophy2
@onready var trophy_3: Trophy = $CanvasLayer / MarginContainer / Panel / HBoxContainer / Trophy3
@onready var trophy_4: Trophy = $CanvasLayer / MarginContainer / Panel / HBoxContainer / Trophy4
@onready var trophy_5: Trophy = $CanvasLayer / MarginContainer / Panel / HBoxContainer / Trophy5
@onready var trophy_6: Trophy = $CanvasLayer / MarginContainer / Panel / HBoxContainer / Trophy6


func _ready() -> void :
    blur.visible = false
    color_rect.visible = false
    panel.visible = false
    panel.scale = Vector2.ZERO
    gpu_particles_2d.visible = false
    check_trophy_unlock()
    pop_panel()

func pop_panel() -> void :
    gpu_particles_2d.visible = true
    blur.visible = true
    color_rect.visible = true
    panel.visible = true
    var tween = create_tween()
    tween.tween_property(panel, "scale", Vector2.ONE, 0.7).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)

    await tween.finished
    button_ok.grab_focus()


func check_trophy_unlock() -> void :
    var _nb_trophy_unlock: = 0
    if GAMES.trophy_already_unlock_1 == false && GAMES.game_data.challenge1:
        trophy_1.visible = true
        _nb_trophy_unlock += 1
    if GAMES.trophy_already_unlock_2 == false && GAMES.game_data.challenge2:
        trophy_2.visible = true
        _nb_trophy_unlock += 1
    if GAMES.trophy_already_unlock_3 == false && GAMES.game_data.challenge3:
        trophy_3.visible = true
        _nb_trophy_unlock += 1
    if GAMES.trophy_already_unlock_4 == false && GAMES.game_data.challenge4:
        trophy_4.visible = true
        _nb_trophy_unlock += 1
    if GAMES.trophy_already_unlock_5 == false && GAMES.game_data.challenge5:
        trophy_5.visible = true
        _nb_trophy_unlock += 1
    if GAMES.trophy_already_unlock_6 == false && GAMES.game_data.challenge6:
        trophy_6.visible = true
        _nb_trophy_unlock += 1

    if _nb_trophy_unlock <= 0 or GAMES.superdash_run:
        _on_button_pressed()

func _on_button_pressed() -> void :
    EVENTS.emit_signal("trophy_resume_free")
    queue_free()
