extends Area2D
class_name New_Platform

@onready var platform_way: TileMapLayer = get_parent()
@onready var label_platform_flex: Label = %Label_platformFlex

@onready var v_indicator: TileMapLayer = $"../V_Indicator"
@onready var h_indicator: TileMapLayer = $"../H_Indicator"
@onready var d_point: TileMapLayer = $"../D_Point"

@export var speed: float
@export var is_looping: bool = false

var starting_signal = false
var link_player: Area2D = null
var platform_flex: int = 0

var start_index: int = 0
var way: Array[Vector2i] = []
var last_modified_end: int = 1
var current_index: int = 0
var is_moving_forward: bool = true
var editor_initial_global_pos: Vector2
var current_tween: Tween

var is_linked_to_door: bool = false
var linked_door_node: Node2D = null
var linked_door_pos: Vector2i = Vector2i.ZERO

const plat_way: Dictionary = {
	"D_A": Vector2i(2,1),
	"B": Vector2i(3,1),
	1: [Vector2i(1,1), null],
	2: [null, Vector2i(1,0)],
	3: [Vector2i(1,1), Vector2i(1,0)],
	4: [Vector2i(0,0), null],
	5: [Vector2i(0,1), null],
	6: [Vector2i(0,0), Vector2i(1,0)],
	8: [null, Vector2i(3,0)],
	9: [Vector2i(1,1), Vector2i(3,0)],
	10: [null, Vector2i(2,0)],
	12: [Vector2i(0,0), Vector2i(3,0)],
}

func _ready() -> void:
	add_to_group("LinkedPlatforms")
	EVENTS.connect("starting", _on_EVENTS_starting)
	EVENTS.connect("superdash_run", _on_superdash_run) # Redirigé proprement
	label_platform_flex.visible = false
	randomize()
	$AudioStreamPlayer2D.pitch_scale = randf_range(1.75, 2.25)
	editor_initial_global_pos = global_position
	is_looping = _check_loop_validity()

# ==========================================
# GESTION DU DÉPLACEMENT ET DE L'AFFICHAGE
# ==========================================

func set_way(new_way: Array[Vector2i]) -> void:
	if new_way.size() > 1 and new_way.front() == new_way.back():
		is_looping = true
		new_way.pop_back()
	way = new_way
	is_looping = _check_loop_validity()
	_draw_path_visuals()

func _check_loop_validity() -> bool:
	if not is_looping or way.size() < 4:
		return false
	var first_cell = way.front()
	var last_cell = way.back()
	var diff = abs(first_cell - last_cell)
	if (diff.x == 1 and diff.y == 0) or (diff.x == 0 and diff.y == 1):
		return true
	return false

func _draw_path_visuals() -> void:
	v_indicator.clear()
	h_indicator.clear()
	d_point.clear()
	if way.is_empty():
		return
	var cell_scores: Dictionary = {}
	for i in range(way.size()):
		var cell = way[i]
		if not cell_scores.has(cell):
			cell_scores[cell] = 0
		var neighbors = []
		if i > 0:
			neighbors.append(way[i - 1])
		elif is_looping and way.size() > 1:
			neighbors.append(way.back())
		if i < way.size() - 1:
			neighbors.append(way[i + 1])
		elif is_looping and way.size() > 1:
			neighbors.append(way.front())
		for n in neighbors:
			if n == cell + Vector2i.UP:    cell_scores[cell] |= 1
			elif n == cell + Vector2i.RIGHT: cell_scores[cell] |= 2
			elif n == cell + Vector2i.DOWN:  cell_scores[cell] |= 4
			elif n == cell + Vector2i.LEFT:  cell_scores[cell] |= 8
	for cell in cell_scores:
		var score = cell_scores[cell]
		if plat_way.has(score):
			var data = plat_way[score]
			if data[0] != null:
				v_indicator.set_cell(cell, 0, data[0])
			if data[1] != null:
				h_indicator.set_cell(cell, 0, data[1])
	if way.size() > 0:
		if is_looping:
			d_point.set_cell(way[start_index], 0, plat_way["B"])
		else:
			d_point.set_cell(way.front(), 0, plat_way["D_A"])
			if way.size() > 1:
				d_point.set_cell(way.back(), 0, plat_way["D_A"])

func move() -> void:
	if not starting_signal or way.size() < 2: 
		return
	_calculate_next_index()
	var next_cell = way[current_index]
	var destination = v_indicator.to_global(v_indicator.map_to_local(next_cell))
	if current_tween and current_tween.is_valid():
		current_tween.kill()
	current_tween = create_tween()
	current_tween.tween_property(self, "global_position", destination, speed).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CIRC)
	current_tween.connect("finished", _on_tween_finished)
	if destination != global_position:
		$AudioStreamPlayer2D.play()

func _calculate_next_index() -> void:
	if is_moving_forward:
		current_index += 1
		if current_index >= way.size():
			if is_looping:
				current_index = 0
			else:
				is_moving_forward = false
				current_index -= 2
	else:
		current_index -= 1
		if current_index < 0:
			if is_looping:
				current_index = way.size() - 1
			else:
				is_moving_forward = true
				current_index = 1

# ==========================================
# FONCTIONS LIÉES À L'ÉDITEUR
# ==========================================

func reset_to_editor() -> void:
	starting_signal = false
	current_index = start_index 
	is_moving_forward = true
	if current_tween and current_tween.is_valid():
		current_tween.kill()
	if way.size() > 0:
		global_position = v_indicator.to_global(v_indicator.map_to_local(way[start_index])) # <-- NOUVEAU
	_draw_path_visuals()
	platformFlexEnd()

# ==========================================
# MÉCANIQUES EXISTANTES (Flex, Event, etc.)
# ==========================================

func platformFlexCombo() -> void:
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

func platformFlexEnd() -> void:
	label_platform_flex.visible = false
	Engine.time_scale = 1
	if GAMES.SteamisRunning && platform_flex >= 3:
		var score: int = platform_flex
		Steam.uploadLeaderboardScore(score, true, PackedInt32Array(), GAMES.leaderboard_handles["PlatformFlex"])
	if platform_flex > 0:
		platform_flex = 0

func _on_area_entered(area: Area2D) -> void:
	if area is Player:
		link_player = area

func _on_area_exited(area: Area2D) -> void:
	if area is Player:
		link_player = null
		platformFlexEnd()

func _on_tween_finished() -> void:
	global_position = v_indicator.to_global(v_indicator.map_to_local(way[current_index]))
	if not is_looping and (current_index == 0 or current_index == way.size() - 1):
		await get_tree().create_timer(speed).timeout
		if not is_inside_tree() or starting_signal == false:
			return
	move()

func _on_EVENTS_starting() -> void:
	if not is_linked_to_door:
		starting_signal = true
		move()

func _on_superdash_run() -> void:
	if is_linked_to_door and not starting_signal:
		starting_signal = true
		move()

func _on_delay_platformflex_timeout() -> void:
	platformFlexEnd()

func try_set_start_pos(grid_pos: Vector2i) -> bool:
	var idx = way.find(grid_pos)
	if idx != -1:
		start_index = idx
		if is_looping:
			_draw_path_visuals()
		reset_to_editor()
		return true
	return false

func reverse_path() -> void:
	if way.size() <= 1: return
	way.reverse()
	start_index = (way.size() - 1) - start_index
	_draw_path_visuals()
	reset_to_editor()

func check_door_opened(door_pos: Vector2i) -> void:
	if is_linked_to_door:
		if linked_door_pos == door_pos:
			starting_signal = true
			move()
		elif linked_door_node == null and linked_door_pos == door_pos:
			starting_signal = true
			move()
