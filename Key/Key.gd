extends Area2D
class_name Keys

var node_map: TileMapLayer = null
var node_door: New_Door = null

@export var move_speed: float = 0.7

@onready var node_cpu_particles_2d: CPUParticles2D = %CPUParticles2D
@onready var node_point_light_2d: PointLight2D = %PointLight2D
@onready var node_audio_stream_player_2d: AudioStreamPlayer2D = %AudioStreamPlayer2D
@onready var node_grp_label_key_collect: Control = %Label_key_collect2
@onready var node_label_key_collect: Label = %Label_key_collect
@onready var node_label_key_need: Label = %Label_key_need

var collected: = false
var player_entered: Area2D = null
var key_tile: Vector2i

func _ready() -> void :
	if not area_entered.is_connected(_on_area_entered):
		area_entered.connect(_on_area_entered)
	var intermediate_node = get_parent()
	if intermediate_node != null and intermediate_node.get_parent() is New_Door:
		node_door = intermediate_node.get_parent()
		if not node_door.is_node_ready():
			await node_door.ready
		node_map = node_door.node_map
	if node_map != null:
		key_tile = node_map.local_to_map(global_position)
		global_position = node_map.map_to_local(key_tile)

func _process(_delta: float) -> void :
	if player_entered:
		var is_idle = player_entered.node_state_machine.current_state.name == "Idle"
		var distance_current = player_entered.global_position.distance_to(global_position)
		var distance_destination = player_entered.destination.distance_to(global_position)
		var is_arriving_here = (distance_destination < 2.0)
		if distance_current < 8.0:
			if is_idle or is_arriving_here:
				check_player_grab()

func check_player_grab() -> void :
	if collected == true: return
	collected = true
	if is_instance_valid(node_door):
		node_door.keys_grabbed += 1
		EVENTS.emit_signal("collect_key", node_door.keys_grabbed, node_door.nb_keys_needed)
		if node_grp_label_key_collect:
			node_grp_label_key_collect.reparent(node_map)
			node_grp_label_key_collect.z_index = 50
			node_grp_label_key_collect.z_as_relative = false
			node_grp_label_key_collect.global_position = global_position - Vector2(12.0, 12.0)
			node_label_key_collect.text = str(node_door.keys_grabbed)
			node_label_key_need.text = str(node_door.nb_keys_needed)
			node_grp_label_key_collect.visible = true
			node_grp_label_key_collect.scale = Vector2.ZERO
			var popup_tween = node_grp_label_key_collect.create_tween()
			popup_tween.tween_property(node_grp_label_key_collect, "scale", Vector2.ONE, 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)
			popup_tween.tween_interval(0.1)
			popup_tween.tween_property(node_grp_label_key_collect, "scale", Vector2.ZERO, 0.4).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
			popup_tween.finished.connect(node_grp_label_key_collect.queue_free)
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
	if area is Player:
		player_entered = area

func _on_area_exited(area: Area2D) -> void :
	if area is Player:
		print("sorti")
		player_entered = null
