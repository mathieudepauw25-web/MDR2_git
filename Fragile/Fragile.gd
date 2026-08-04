extends Area2D
class_name Fragile

@onready var node_animation_player: AnimationPlayer = %AnimationPlayer
@onready var node_tile_map_layer_floor: TileMapLayer = owner
@onready var node_timer_repop: Timer = %Timer_repop
@onready var sprite: Sprite2D = %Sprite2D

@export var delay_repop: = 4.0
var link_player: Area2D = null
var is_falling: = false
var base_offset: Vector2 = Vector2.ZERO

@warning_ignore("unused_signal")
signal erase_floor_tile(v_global_position)

func reset_to_editor() -> void:
	is_falling = false
	node_timer_repop.stop()
	node_animation_player.seek(0, true)
	node_animation_player.stop()
	sprite.position = base_offset

func set_skin(base_texture: Texture2D, atlas_coords: Vector2i, true_square: bool) -> void:
	var atlas = AtlasTexture.new()
	atlas.atlas = base_texture
	var start_x = atlas_coords.x * 16
	if true_square:
		atlas.region = Rect2(start_x, atlas_coords.y * 16, 16, 16)
		base_offset = Vector2.ZERO
	else:
		atlas.region = Rect2(start_x, atlas_coords.y * 16 - 1, 17, 17)
		base_offset = Vector2(0.5, -0.5)
	sprite.texture = atlas
	sprite.position = base_offset

func collapsing() -> void :
	node_animation_player.play("Collapse")
	$Cracking.play()

func fall() -> void :
	is_falling = true
	EVENTS.emit_signal("erase_floor_tile", global_position)
	node_animation_player.play("Fall")
	node_timer_repop.start(delay_repop)
	if link_player != null:
		if link_player.node_state_machine.current_state.name == "Idle":
			link_player.snap_grid()

func _on_area_entered(area: Area2D) -> void :
	if is_falling: return
	if area is Player:
		link_player = area
		collapsing()

func _on_area_exited(area: Area2D) -> void :
	if area is Player:
		link_player = null

func _on_animation_player_animation_finished(anim_name: StringName) -> void :
	if anim_name == "Collapse":
		fall()
	elif anim_name == "Fall":
		sprite.position = base_offset

func _on_timer_repop_timeout() -> void :
	EVENTS.emit_signal("create_floor_tile", global_position)
	is_falling = false
	node_animation_player.play_backwards("Fall")
	$Repop.play()
