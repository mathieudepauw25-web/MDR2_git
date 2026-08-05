extends Area2D
class_name Keys

var node_map: TileMapLayer = null
var node_door: Door = null

@export var move_speed: float = 0.7

@onready var node_cpu_particles_2d: CPUParticles2D = %CPUParticles2D
@onready var node_point_light_2d: PointLight2D = %PointLight2D
@onready var node_audio_stream_player_2d: AudioStreamPlayer2D = %AudioStreamPlayer2D

var collected: = false
var player_entered: Area2D = null

func _ready() -> void :
	var intermediate_node = get_parent()
	if intermediate_node != null and intermediate_node.get_parent() is Door:
		node_door = intermediate_node.get_parent()
		if not node_door.is_node_ready():
			await node_door.ready
		node_map = node_door.node_map
	if node_map != null:
		var key_tile = node_map.local_to_map(global_position)
		global_position = node_map.map_to_local(key_tile)

func _process(_delta: float) -> void :
	if player_entered and player_entered.node_state_machine.current_state.name == "Idle" and player_entered.global_position == global_position:
		check_player_grab()

func check_player_grab() -> void :
	if collected == true: return
	collected = true
	if is_instance_valid(node_door):
		EVENTS.emit_signal("collect_key", node_door.nb_key + 1, node_door.nb_keys_needed)
		node_cpu_particles_2d.visible = true
		node_point_light_2d.visible = false
		node_audio_stream_player_2d.pitch_scale = randf_range(0.98, 1.02)
		node_audio_stream_player_2d.play()
		var tween = create_tween().set_parallel()
		tween.tween_property(self, "global_position", node_door.global_position, move_speed).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
		tween.tween_property(self, "rotation", 180, 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
		tween.tween_property(self, "scale", Vector2(0.9, 0.9), 0.5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_ELASTIC)
	else:
		queue_free()

func _on_area_entered(area: Area2D) -> void :
	if area is Door:
		queue_free()
	if area is Player:
		player_entered = area

func _on_area_exited(area: Area2D) -> void :
	if area is Player:
		player_entered = null
