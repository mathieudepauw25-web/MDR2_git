extends Area2D
class_name Fragile

@onready var node_animation_player: AnimationPlayer = %AnimationPlayer
@onready var node_tile_map_layer_floor: TileMapLayer = owner
@onready var node_timer_repop: Timer = %Timer_repop

@export var delay_repop: = 4.0
var link_player: Area2D = null
var is_falling: = false

signal erase_floor_tile(v_global_position)

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

func _on_timer_repop_timeout() -> void :
	EVENTS.emit_signal("create_floor_tile", global_position)
	is_falling = false
	node_animation_player.play_backwards("Fall")
	$Repop.play()
