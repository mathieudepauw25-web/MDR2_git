extends State
class_name PlayerStateFall

@onready var node_collision_shape_2d: CollisionShape2D = %CollisionShape2D
@onready var node_splash: AudioStreamPlayer = %Splash

func state_enter() -> void :
	node_collision_shape_2d.set_deferred("disabled", true)

	var pitch = randf_range(0.7, 1.3)
	node_splash.pitch_scale = pitch
	node_splash.play()


func state_exit() -> void :
	node_collision_shape_2d.set_deferred("disabled", false)
	owner.clean_buffer()
