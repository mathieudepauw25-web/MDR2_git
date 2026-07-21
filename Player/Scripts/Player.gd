extends Area2D
class_name Player

@onready var node_state_machine: StateMachine = %StateMachine
@onready var node_map: TileMapLayer = %MAP
@onready var node_label_move: Label = %LabelMove
@onready var node_label_dash: Label = %LabelDash
@onready var node_animation_player: AnimationPlayer = %AnimationPlayer
@onready var node_tile_map_layer_fragile: TileMapLayer = %tileMapLayer_fragile
@onready var node_timer_first_move: Timer = %Timer_first_move
@onready var node_timer_pok: Timer = %Timer_pok
@onready var node_smoke: AnimatedSprite2D = %Smoke
@onready var node_grp_label_key_collect: Control = %Label_key_collect2
@onready var node_label_key_collect: Label = %Label_key_collect
@onready var node_label_key_need: Label = %Label_key_need
@onready var node_visual_start: Node2D = %Visual_start

@export var buffer_timing: float = 0.5
@export var timming_first_move: float = 0.35
var starting_signal = false
var speed: float = 0.15
var speed_on_ice: float = 0.08
var speed_dash: float = 0.2
var direction: Vector2 = Vector2.ZERO
var previous_position: = global_position
var previous_safe_place: = global_position
var destination: Vector2 = global_position
var buffer_move: String = ""
var buffer_dash: String = ""
var is_first_move: = true
var looking_left: = false
var on_tile_ice: = false
var sliding = false
var superdash: bool = false
var arrival = false
var link_platform: Area2D = null

# Mes variables
var active_tween: Tween
var is_poking: bool = false
var action_start_position: Vector2 = global_position
var portal_momentum: int = 0
var cheat_buffer: String = ""
var teleport_immunity_frames: int = 0

enum TileType{
	FLOOR, 
	WALL, 
	ICE, 
	PLATFORMWAY, 
	FRAGILE, 
	HIDDEN, 
}


func _ready() -> void :
	EVENTS.connect("arrival", _on_EVENTS_arrival)
	EVENTS.connect("collect_key", _on_EVENTS_collect_key)
	snap_grid()
	show_game_input()
	var current_skin = GESTIONNAIRESKIN.player_data.equipped_skin
	if $AnimatedSprite2D.sprite_frames.has_animation(current_skin):
		$AnimatedSprite2D.play(current_skin)
	%ParticuleDash.texture = $AnimatedSprite2D.sprite_frames.get_frame_texture($AnimatedSprite2D.animation, 0)

func _process(_delta: float) -> void :
	$StateMachine / buffer_move.text = buffer_move
	$StateMachine / buffer_dash.text = buffer_dash
	if arrival: return
	if Input.is_action_just_pressed("move_right"): add_buffer_move("move_right")
	if Input.is_action_just_pressed("move_up"): add_buffer_move("move_up")
	if Input.is_action_just_pressed("move_left"): add_buffer_move("move_left")
	if Input.is_action_just_pressed("move_down"): add_buffer_move("move_down")
	if Input.is_action_just_pressed("dash_right"): add_buffer_dash("dash_right")
	if Input.is_action_just_pressed("dash_up"): add_buffer_dash("dash_up")
	if Input.is_action_just_pressed("dash_left"): add_buffer_dash("dash_left")
	if Input.is_action_just_pressed("dash_down"): add_buffer_dash("dash_down")

	match node_state_machine.current_state.name:
		"Idle":
			if tile_is_type(TileType.ICE, node_map.local_to_map(global_position)) and direction != Vector2.ZERO:
				slide(direction)
				return

			if buffer_move != "":
				direction = get_input_direction(buffer_move)
				move(direction)
			elif buffer_dash != "":
				direction = get_input_direction(buffer_dash)
				dash(direction)

			if link_platform != null:
				global_position = link_platform.global_position

		"Move":
			pass
		"Slide":
			if direction != Vector2.ZERO:
				if !sliding: slide(direction)
			else:
				node_state_machine.set_state("Idle")


func add_buffer_move(input: String) -> void :
	if buffer_dash != "": return
	if Engine.time_scale == 0: return
	launch_starting_signal()
	buffer_move = input
	node_label_move.text = buffer_move
	$buffer_move.start(buffer_timing)


func add_buffer_dash(input: String) -> void :
	if Engine.time_scale == 0: return
	launch_starting_signal()
	buffer_move = ""
	buffer_dash = input
	node_label_dash.text = buffer_dash
	$buffer_dash.start(buffer_timing)


func delete_buffer_move() -> void :
	if buffer_move == "": return
	buffer_move = ""
	node_label_move.text = buffer_move

func delete_buffer_dash() -> void :
	if buffer_dash == "": return
	buffer_dash = ""
	node_label_dash.text = buffer_dash


func show_game_input() -> void :
	var nb_gamepad = Input.get_connected_joypads().size()
	if nb_gamepad > 0:
		%Move_manette.visible = true
		%Dash_manette.visible = true
	else:
		%Move_clavier.visible = true
		%Dash_clavier.visible = true

func get_input_direction(string_direction: String) -> Vector2:
	var return_value = Vector2.ZERO
	match string_direction:
		"move_right": return_value = Vector2.RIGHT
		"move_up": return_value = Vector2.UP
		"move_left": return_value = Vector2.LEFT
		"move_down": return_value = Vector2.DOWN
		"dash_right": return_value = Vector2.RIGHT
		"dash_up": return_value = Vector2.UP
		"dash_left": return_value = Vector2.LEFT
		"dash_down": return_value = Vector2.DOWN
	check_looking(return_value)
	return return_value

func check_looking(v_direction: Vector2) -> void :
	if v_direction == Vector2.LEFT:
		if looking_left == false:
			looking_left = true
			scale.x = - scale.x
	if v_direction == Vector2.RIGHT:
		if looking_left == true:
			looking_left = false
			scale.x = abs(scale.x)

func move(_direction: Vector2, stats_increase: = true) -> void :
	action_start_position = global_position
	if stats_increase: EVENTS.emit_signal("player_move")
	delete_buffer_move()
	previous_position = global_position
	destination = global_position + _direction * node_map.rendering_quadrant_size
	var tile_destination = node_map.local_to_map(destination)
	var destination_is_wall: = tile_is_type(TileType.WALL, tile_destination)
	var destination_is_ice: = tile_is_type(TileType.ICE, tile_destination)

	if destination_is_wall:
		var destination_wall: = global_position + _direction * (16 - 9)
		pok_a_wall(destination_wall)
		node_state_machine.set_state("Move")
		return
	if destination_is_ice:
		if on_tile_ice == true:
			slide(direction)
			return

	var tween = get_new_tween()
	tween.tween_property(self, "global_position", destination, speed).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CIRC)
	tween.connect("finished", _on_tween_finished)

	if is_first_move:
		node_timer_first_move.start(timming_first_move)

	node_state_machine.set_state("Move")

func dash(_direction: Vector2, remaining_tiles: int = 0) -> void :
	action_start_position = global_position
	EVENTS.emit_signal("player_dash")
	delete_buffer_dash()
	superdash = false
	var dash_factor: int = 4
	var index_repeat: int = 0
	var portal_step: int = 999
	
	if remaining_tiles > 0:
		dash_factor = remaining_tiles
	else:
		if Input.is_action_pressed("move_right"): superdash = true
		if Input.is_action_pressed("move_up"): superdash = true
		if Input.is_action_pressed("move_left"): superdash = true
		if Input.is_action_pressed("move_down"): superdash = true
		if superdash and GAMES.game_data.option_superdash and GAMES.all_star_unlock:
			dash_factor = 5
			GAMES.superdash_run = true
			EVENTS.emit_signal("superdash_run")
		else:
			superdash = false
	while index_repeat < dash_factor:
		index_repeat += 1
		destination = global_position + _direction * (16 * index_repeat)
		previous_position = global_position + _direction * (16 * (index_repeat - 1))
		var tile_destination = node_map.local_to_map(destination)
		if is_portal_at(tile_destination):
			if portal_step == 999:
				portal_step = index_repeat
			destination = global_position + _direction * (16 * index_repeat)
			portal_momentum = dash_factor - index_repeat
			break 
		var destination_is_wall: = tile_is_type(TileType.WALL, tile_destination)
		var destination_is_hidden: = tile_is_type(TileType.HIDDEN, tile_destination)
		var destination_is_pit: = !tile_is_type(TileType.FLOOR, tile_destination)
		var destination_is_ice: = tile_is_type(TileType.ICE, tile_destination)
		if destination_is_wall:
			var destination_wall: = global_position + _direction * ((16 * index_repeat) - 9)
			pok_a_wall(destination_wall, 0.05 * index_repeat, true)
			node_state_machine.set_state("Dash")
			return
		if destination_is_pit == true and destination_is_hidden == false and index_repeat < dash_factor:
			if index_repeat <= portal_step:
				make_water_dash(destination)
		if destination_is_ice:
			on_tile_ice = true

	var final_speed_dash: float = speed_dash
	if superdash: final_speed_dash += 0.05
	var tween = get_new_tween()
	tween.tween_property(self, "global_position", destination, final_speed_dash).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	tween.connect("finished", _on_tween_finished)

	node_state_machine.set_state("Dash")

func slide(_direction: Vector2) -> void :
	action_start_position = global_position
	previous_position = global_position
	destination = global_position + _direction * node_map.rendering_quadrant_size
	var tile_destination = node_map.local_to_map(destination)
	var destination_is_wall: = tile_is_type(TileType.WALL, tile_destination)
	var destination_is_not_ice: = !tile_is_type(TileType.ICE, tile_destination)

	if destination_is_wall:
		destination = global_position + _direction * (16 - 9)
		pok_a_wall(destination)
		return
	if destination_is_not_ice:
		on_tile_ice = false
		move(_direction, false)
		return
	else: on_tile_ice = true

	var tween = get_new_tween()
	tween.tween_property(self, "global_position", destination, speed_on_ice).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_LINEAR)
	tween.connect("finished", _on_sliding_end)
	sliding = true

	node_state_machine.set_state("Slide")

func make_water_dash(v_global_destination) -> void :
	EVENTS.emit_signal("waterDash", v_global_destination, direction)

func tile_is_type(tile_type: int, tile_check: Vector2) -> bool:
	var Stile_is_type = false
	if node_map.get_child(tile_type).get_cell_source_id(tile_check) != -1:
		Stile_is_type = true

	return Stile_is_type

func pok_a_wall(_destination: Vector2, speed_pok: float = 0.05, dashing: bool = false) -> void :
	is_poking = true
	EVENTS.emit_signal("player_pok")
	var tween = get_new_tween()
	if dashing:
		tween.tween_property(self, "global_position", _destination, speed_pok).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	else:
		tween.tween_property(self, "global_position", _destination, speed_pok).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(self, "global_position", previous_position, 0.2).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween.connect("finished", _on_tween_finished)

	direction = Vector2.ZERO
	await get_tree().create_timer(speed_pok - 0.03).timeout
	await get_tree().process_frame
	if tween and tween.is_valid():
		node_state_machine.set_state("Pok")



func fall_into_pit(_destination: Vector2) -> void :
	var current_tile = node_map.local_to_map(global_position)
	var tile_is_hidden: = tile_is_type(TileType.HIDDEN, current_tile)
	if tile_is_hidden: return
	EVENTS.emit_signal("player_fall")
	direction = Vector2.ZERO
	buffer_move = ""
	buffer_dash = ""
	is_first_move = true
	var tween = get_new_tween()
	if _destination != global_position:
		tween.tween_property(self, "global_position", _destination, speed).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CIRC)
	tween.tween_property(self, "scale", Vector2.ZERO, 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "global_position", previous_safe_place, 0.1).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(self, "scale", Vector2(1, 1), 0.1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

	tween.connect("finished", _on_tween_finished)
	EVENTS.emit_signal("splash", global_position)

	node_state_machine.set_state("Fall")


func snap_grid() -> void :
	if link_platform != null: return
	if node_state_machine.current_state.name != "Idle": return
	var player_tile = node_map.local_to_map(global_position)
	var is_pit: = !tile_is_type(TileType.FLOOR, player_tile)
	var is_fragile: = tile_is_type(TileType.FRAGILE, player_tile)
	var is_ice: = tile_is_type(TileType.ICE, player_tile)
	global_position = node_map.map_to_local(player_tile)
	on_tile_ice = false
	if is_ice:
		on_tile_ice = true
	if is_pit:
		fall_into_pit(global_position)
		return
	if is_fragile == false and on_tile_ice == false and not is_portal_at(player_tile):
		previous_safe_place = global_position

func clean_buffer() -> void :
	buffer_move = ""
	buffer_dash = ""

func check_pressed_input() -> void :
	if is_first_move == false:
		if Input.is_action_pressed("move_right"): add_buffer_move("move_right")
		if Input.is_action_pressed("move_up"): add_buffer_move("move_up")
		if Input.is_action_pressed("move_left"): add_buffer_move("move_left")
		if Input.is_action_pressed("move_down"): add_buffer_move("move_down")

		if buffer_move == "" and buffer_dash == "":
			is_first_move = true

func launch_starting_signal() -> void :
	if starting_signal == false:
		starting_signal = true
		EVENTS.emit_signal("starting")
		node_visual_start.visible = false


func _on_tween_finished() -> void :
	is_poking = false
	node_state_machine.set_state("Idle")

func _on_sliding_end() -> void :
	sliding = false

func _on_buffer_end() -> void :
	delete_buffer_move()

func _on_bufferDash_end() -> void :
	delete_buffer_dash()

func _on_state_machine_state_changed(_new_state: Variant) -> void :
	snap_grid()

func _on_area_entered(area: Area2D) -> void :
	if area is Platform:
		link_platform = area

func _on_area_exited(area: Area2D) -> void :
	if area is Platform:
		link_platform = null
		if node_state_machine.get_state_name() == "Idle":
			snap_grid()

func _on_timer_first_move_timeout() -> void :
	is_first_move = false
	check_pressed_input()

func _on_EVENTS_arrival() -> void :
	arrival = true

func _on_EVENTS_collect_key(nb_key: int, nb_key_need: int) -> void :
	node_label_key_collect.text = str(nb_key)
	node_label_key_need.text = str(nb_key_need)
	var tile_position: = node_map.local_to_map(global_position)
	var pickup_position: = node_map.map_to_local(tile_position)
	pickup_position -= Vector2(12.0, 12.0)
	node_grp_label_key_collect.visible = true
	node_grp_label_key_collect.global_position = pickup_position
	node_grp_label_key_collect.scale = Vector2.ZERO
	var tween = create_tween()

	tween.tween_property(node_grp_label_key_collect, "scale", Vector2.ONE * 1, 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property(node_grp_label_key_collect, "scale", Vector2.ZERO, 0.7).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_ELASTIC)

	await tween.finished
	node_grp_label_key_collect.visible = false


func _on_smoke_animation_finished() -> void :
	node_smoke.visible = false


func _on_inaction_timeout() -> void :
	EVENTS.emit_signal("player_inaction")

##################### Mes ajouts #####################

func teleport_to_portal(entrance_pos: Vector2, exit_pos: Vector2) -> void:
	is_poking = false
	var grid_size = node_map.rendering_quadrant_size
	var current_state = node_state_machine.current_state.name
	var saved_direction = direction
	var tiles_left: int = 0
	if current_state == "Dash":
		tiles_left = portal_momentum
		portal_momentum = 0 
	elif saved_direction != Vector2.ZERO:
		var distance_to_end = entrance_pos.distance_to(destination)
		tiles_left = round(distance_to_end / grid_size)
	if active_tween and active_tween.is_valid():
		active_tween.kill()
	global_position = exit_pos
	previous_position = exit_pos
	if link_platform == null:
		if not is_portal_at(node_map.local_to_map(action_start_position)):
			previous_safe_place = action_start_position
	action_start_position = exit_pos 
	destination = exit_pos
	if tiles_left > 0 and saved_direction != Vector2.ZERO:
		if current_state == "Slide":
			slide(saved_direction)
		elif current_state == "Dash":
			dash(saved_direction, tiles_left)
		elif current_state == "Move":
			move(saved_direction, false)
	else:
		direction = Vector2.ZERO
		clean_buffer()
		node_state_machine.set_state("Idle")
		snap_grid()

func get_new_tween() -> Tween:
	active_tween = create_tween()
	return active_tween

func is_portal_at(tile_pos: Vector2i) -> bool:
	for portal in get_tree().get_nodes_in_group("Portals"):
		if node_map.local_to_map(portal.global_position) == tile_pos:
			return true
	return false

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.unicode == 0:
			return
		var char_typed = char(event.unicode).to_lower()
		cheat_buffer += char_typed
		if cheat_buffer.length() > 10:
			cheat_buffer = cheat_buffer.substr(cheat_buffer.length() - 10)
		if cheat_buffer.ends_with("mdr"):
			GESTIONNAIRESKIN.unlock_skin("Prince")
			GESTIONNAIRESKIN.equip_skin("Prince")
			$AnimatedSprite2D.play("Prince")
			%ParticuleDash.texture = $AnimatedSprite2D.sprite_frames.get_frame_texture($AnimatedSprite2D.animation, 0)
			%M_D_R.play()

func _physics_process(_delta: float) -> void:
	if teleport_immunity_frames > 0:
		teleport_immunity_frames -= 1
