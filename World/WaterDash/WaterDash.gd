extends AnimationOS
class_name Anim_WaterDash

var dash_left: = false
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var node_audio_stream_player_2d: AudioStreamPlayer2D = %AudioStreamPlayer2D

func _ready() -> void :
	if dash_left:
		animation_player.play("ready_reverse")
	else:
		animation_player.play("ready")

	node_audio_stream_player_2d.pitch_scale = randf_range(0.7, 1.3)
	node_audio_stream_player_2d.play()

func _process(delta: float) -> void :
	if has_overlapping_areas():
		queue_free()


func _on_animation_player_animation_finished(anim_name: StringName) -> void :
	queue_free()
