extends State
class_name PlayerStateMove

@onready var node_audio_move: AudioStreamPlayer = %Move
@onready var timer_inaction: Timer = $"../../inaction"

func state_enter() -> void :
    if owner.node_animation_player.is_playing(): owner.node_animation_player.stop()
    owner.node_animation_player.play("move")

    node_audio_move.pitch_scale = randf_range(2, 3)
    node_audio_move.play()

func state_exit() -> void :
    if owner.link_platform != null:
        owner.link_platform.platformFlexCombo()
