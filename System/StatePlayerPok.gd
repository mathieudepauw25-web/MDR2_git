extends State
class_name PlayerStatePoke

@onready var node_collision_shape_2d: CollisionShape2D = %CollisionShape2D
@onready var node_audio_pok: AudioStreamPlayer = %Pok
@onready var node_camera_2d: Camera = %Camera2D

func state_enter() -> void :
	EVENTS.emit_signal("shake_camera")

	node_audio_pok.pitch_scale = randf_range(0.85, 1.15)
	node_audio_pok.play()
	if owner.node_animation_player.is_playing(): owner.node_animation_player.stop()
	owner.node_animation_player.play("pok")

	node_camera_2d.dezoom_dash(1.05, 0.25)


func state_exit() -> void :

	owner.clean_buffer()
