extends Node2D
class_name Secret

@export var index_star: = 0
@export var secret_data: Resource = null: set = set_secret_data
@onready var node_sprite_2d: Sprite2D = %Sprite2D2
@onready var node_map: TileMapLayer = %MAP
@onready var node_animation_player: AnimationPlayer = %AnimationPlayer
@onready var node_cpu_particles_2d: CPUParticles2D = %CPUParticles2D
@onready var node_point_light_2d: PointLight2D = %PointLight2D
@onready var node_audio_stream_player_2d: AudioStreamPlayer2D = %AudioStreamPlayer2D
@onready var vfx_grab_star: AnimatedSprite2D = $grab_star
@onready var sfx_grab_star: AudioStreamPlayer = $sfx_grab_star

var collected: = false
var player_entered: Node2D = null
var follow_player: = false

func _ready() -> void :

    if GAMES.game_data.best_global_time >= GAMES.game_data.defaut_highscore:
        queue_free()

    var secret_tile = node_map.local_to_map(global_position)
    global_position = node_map.map_to_local(secret_tile)

    node_sprite_2d.set_modulate(secret_data.secret_color_modulate)
    node_cpu_particles_2d.set_modulate(secret_data.secret_color_modulate)

    check_already_collect()

func _process(delta: float) -> void :
    if player_entered != null:
        check_player_grab(player_entered)
        if follow_player:
            global_position = player_entered.global_position

func check_player_grab(area: Area2D) -> void :
    if collected == true: return
    if area is Player:
        if area.node_state_machine.current_state.name != "Idle": return
        collected = true
        node_animation_player.play("collect")
        vfx_grab_star.play()
        sfx_grab_star.play()
        node_cpu_particles_2d.amount = 20
        node_cpu_particles_2d.position.y = -6
        EVENTS.emit_signal("collect_start", index_star)
        GAMES.setAchievement(secret_data.ref_steam_achievement)
        follow_player = true

func set_secret_data(value: Resource) -> void :
    secret_data = value

func check_already_collect() -> void :
    match index_star:
        1: if GAMES.game_data.star1: update_visuel_already_collect()
        2: if GAMES.game_data.star2: update_visuel_already_collect()
        3: if GAMES.game_data.star3: update_visuel_already_collect()
        4: if GAMES.game_data.star4: update_visuel_already_collect()
        5: if GAMES.game_data.star5: update_visuel_already_collect()
        6: if GAMES.game_data.star6: update_visuel_already_collect()

func update_visuel_already_collect() -> void :
    modulate = Color(1, 1, 1, 0.3)
    node_cpu_particles_2d.visible = false
    node_point_light_2d.visible = false
    node_audio_stream_player_2d.stop()

func _on_area_entered(area: Area2D) -> void :
    if area is Player:
        player_entered = area


func _on_area_exited(area: Area2D) -> void :
    if area is Player:
        if follow_player == false:
            player_entered = null

func _on_animation_player_animation_finished(anim_name: StringName) -> void :
    if anim_name == "collect":
        queue_free()
