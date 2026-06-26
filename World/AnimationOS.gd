extends Area2D
class_name AnimationOS

@export var sound_play = null

func _on_animated_sprite_2d_animation_finished() -> void :
    queue_free()
