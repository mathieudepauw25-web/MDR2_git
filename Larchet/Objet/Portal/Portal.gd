extends Area2D
class_name Portal

@export var target_portal: Portal
@onready var node_map: TileMapLayer = %MAP
@onready var current_tile: Vector2 = node_map.local_to_map(global_position)
@onready var node_timer: Timer = %Timer
@onready var TP_Sound: AudioStreamPlayer = $TP
#var link_platform: Area2D = null
#var platform_offset: Vector2 = Vector2.ZERO

func _ready() -> void:
	add_to_group("Portals")
	snap_grid()
	"""var overlapping_areas = get_overlapping_areas()
	for area in overlapping_areas:
		print("oui")
		if area is Platform:
			link_platform = area
			#platform_offset = global_position - area.global_position
			break

func _process(delta: float) -> void:
	if link_platform != null:
		global_position = link_platform.global_position #+ platform_offset
"""

func _on_area_entered(area: Area2D) -> void:
	if area is Player:
		if area.teleport_immunity_frames > 0:
			return
		if target_portal:
			area.teleport_immunity_frames = 2 
			area.teleport_to_portal(global_position, target_portal.global_position)
			TP_Sound.play()
			target_portal.start_auto_return()

func _on_area_exited(area: Area2D) -> void:
	if area is Player:
		node_timer.stop()

func snap_grid() -> void :
	current_tile = node_map.local_to_map(global_position)
	global_position = node_map.map_to_local(current_tile)

func start_auto_return() -> void:
	node_timer.start()

func _on_timer_timeout() -> void:
	var player_still_here: Player = null
	for area in get_overlapping_areas():
		if area is Player:
			player_still_here = area
			break
	if player_still_here != null and target_portal:
		player_still_here.teleport_immunity_frames = 2
		player_still_here.teleport_to_portal(global_position, target_portal.global_position)
		TP_Sound.play()
		target_portal.start_auto_return()
