extends Area2D
class_name Portal

@export var target_portal: Portal
@onready var node_timer: Timer = %Timer
@onready var TP_Sound: AudioStreamPlayer = $TP

var node_map: TileMapLayer = null
var current_tile: Vector2i = Vector2i.ZERO

var target_portal_pos: Vector2i = Vector2i.ZERO
var target_portal_node: Node2D = null
#var link_platform: Area2D = null
#var platform_offset: Vector2 = Vector2.ZERO

func _ready() -> void:
	if not area_entered.is_connected(_on_area_entered):
		area_entered.connect(_on_area_entered)
	if not area_exited.is_connected(_on_area_exited):
		area_exited.connect(_on_area_exited)
	add_to_group("Portals")
	var parent = get_parent()
	if parent != null and parent.has_node("MAP"):
		node_map = parent.get_node("MAP")
	elif parent != null and parent.find_child("MAP", true, false) != null:
		node_map = parent.find_child("MAP", true, false)
	else:
		node_map = get_node_or_null("%MAP")
	if node_map != null:
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
		else:
			if area.active_tween and area.active_tween.is_valid():
				area.active_tween.kill()
			area.is_poking = true 
			area.direction = Vector2.ZERO
			area.clean_buffer()
			var bounce_dest = area.previous_position
			if node_map:
				var dest_tile = node_map.local_to_map(area.previous_position)
				bounce_dest = node_map.map_to_local(dest_tile)
			area.destination = bounce_dest
			var tween = area.get_new_tween()
			tween.tween_property(area, "global_position", bounce_dest, 0.25).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
			var sprite = area.get_node_or_null("AnimatedSprite2D")
			if sprite:
				var sprite_tween = area.create_tween()
				sprite_tween.tween_property(sprite, "position:y", -14.0, 0.125).set_ease(Tween.EASE_OUT)
				sprite_tween.tween_property(sprite, "position:y", 0.0, 0.125).set_ease(Tween.EASE_IN)
			tween.connect("finished", area._on_tween_finished)
			EVENTS.emit_signal("player_pok")

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
