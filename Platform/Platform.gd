extends Area2D
class_name Platform

@onready var node_map: TileMapLayer = %MAP
@onready var current_tile: Vector2 = node_map.local_to_map(global_position)
@onready var label_platform_flex: Label = %Label_platformFlex

@export var speed: float
@export var canRightLeft: = true
@export var canUpDown: = true
@export var wait_porte2: bool = false

var starting_signal = false
var link_player: Area2D = null
var direction: = Vector2.ZERO
var previous_tile: = Vector2.ZERO
var index_map_platformway: = 3
var platform_flex: int = 0

func _ready() -> void :
	EVENTS.connect("starting", _on_EVENTS_starting)
	EVENTS.connect("door2", _on_EVENTS_door2)
	EVENTS.connect("superdash_run", _on_EVENTS_door2)
	label_platform_flex.visible = false
	snap_grid()
	randomize()
	$AudioStreamPlayer2D.pitch_scale = randf_range(1.75, 2.25)


func move() -> void :
	if starting_signal == false: return
	direction = find_direction()
	var destination = global_position + (direction * 16)
	var tween = create_tween()
	tween.tween_property(self, "global_position", destination, speed).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CIRC)
	tween.connect("finished", _on_tween_finished)
	if destination != global_position:
		$AudioStreamPlayer2D.play()


func find_direction() -> Vector2:
	direction = Vector2.ZERO
	current_tile = node_map.local_to_map(global_position)
	var array_tiles: = []
	if canRightLeft: array_tiles.append_array([Vector2.RIGHT, Vector2.LEFT])
	if canUpDown: array_tiles.append_array([Vector2.UP, Vector2.DOWN])

	for check_direction in array_tiles:
		var checking_tile = current_tile + check_direction
		if node_map.get_child(index_map_platformway).get_cell_source_id(checking_tile) != -1:
			if checking_tile != previous_tile:
				direction = check_direction

	previous_tile = current_tile
	return direction


func snap_grid() -> void :
	current_tile = node_map.local_to_map(global_position)
	global_position = node_map.map_to_local(current_tile)

func platformFlexCombo() -> void :
	platform_flex += 1
	print(platform_flex)
	$delay_platformflex.start()
	if platform_flex >= 2:
		var tween = create_tween().set_parallel(true)
		var _modulo5 = platform_flex % 5
		var modulo10 = platform_flex % 10
		label_platform_flex.visible = true
		label_platform_flex.text = str(platform_flex)
		label_platform_flex.position = Vector2(-50, -5)
		label_platform_flex.scale = Vector2.ZERO
		$AudioStreamPlayer.pitch_scale = clamp((0.75 + (0.05 * (platform_flex - 2))), 0.75, 3)
		$AudioStreamPlayer.play()
		if modulo10 == 0:
			label_platform_flex.text = "Speed Up"
			GAMES.change_gameEngine_time(0.2)

		tween.tween_property(label_platform_flex, "position", Vector2(-50, -27), 0.35).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
		tween.tween_property(label_platform_flex, "scale", Vector2.ONE, 0.35).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)

func platformFlexEnd() -> void :
	label_platform_flex.visible = false
	Engine.time_scale = 1
	if GAMES.SteamisRunning && platform_flex >= 3:
		var score: int = platform_flex
		Steam.uploadLeaderboardScore(score, true, PackedInt32Array(), GAMES.leaderboard_handles["PlatformFlex"])
		print("Upload best platformFlex on Steam : ", score)

	if platform_flex > 0:
		platform_flex = 0
		print("reset platFormFlex")


func _on_area_entered(area: Area2D) -> void :
	if area is Player:
		link_player = area		

func _on_area_exited(area: Area2D) -> void :
	if area is Player:
		link_player = null
		platformFlexEnd()

func _on_tween_finished() -> void :
	snap_grid()
	move()

func _on_EVENTS_starting() -> void :
	if wait_porte2 == false:
		starting_signal = true
		move()

func _on_EVENTS_door2() -> void :
	if wait_porte2 == true && starting_signal == false:
		starting_signal = true
		move()


func _on_delay_platformflex_timeout() -> void :
	platformFlexEnd()
