extends State
class_name PlayerStateDash

@onready var node_particule_dash: CPUParticles2D = %ParticuleDash
@onready var node_particule_superdash: GPUParticles2D = $"../../ParticlesSuperdash"
@onready var node_smoke: AnimatedSprite2D = %Smoke
@onready var node_camera_2d: Camera = %Camera2D
@onready var node_audio_dash: AudioStreamPlayer = %Dash
@onready var sfx_superdash: AudioStreamPlayer = %Superdash

func state_enter() -> void :
    if owner.node_animation_player.is_playing(): owner.node_animation_player.stop()
    owner.node_animation_player.play("dash")
    node_particule_dash.emitting = true

    var value_dezoom: float = 0.95
    var anim_name: String = "dash"
    if owner.superdash == true:
        value_dezoom = 0.8
        sfx_superdash.play()
        $"../../grab_star".play()
    node_camera_2d.dezoom_dash(value_dezoom)

    node_audio_dash.pitch_scale = randf_range(0.7, 1.3)
    node_audio_dash.play()

    node_smoke.global_position = owner.global_position
    node_smoke.offset.x = owner.direction.x * 15
    node_smoke.scale.x = 1
    if owner.direction == Vector2.LEFT:
        node_smoke.offset.x = owner.direction.x * -15
        node_smoke.scale.x = -1
    node_smoke.visible = true
    node_smoke.frame = 0
    if owner.direction == Vector2.DOWN or owner.direction == Vector2.UP:
        anim_name = "dashUD"
    node_smoke.play(anim_name)

    if owner.superdash and GAMES.game_data.option_superdash and GAMES.all_star_unlock:
        node_particule_superdash.emitting = true

func state_exit() -> void :
    node_particule_dash.emitting = false
    node_particule_superdash.emitting = false
    if owner.superdash and GAMES.game_data.option_superdash and GAMES.all_star_unlock:
        owner.buffer_move = ""
