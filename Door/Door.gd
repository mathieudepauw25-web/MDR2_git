extends Area2D
class_name Door

@onready var node_map: TileMapLayer = %MAP
@onready var node_tile_map_layer_wall: TileMapLayer = %tileMapLayer_wall
@onready var node_bulle: TextureRect = %Bulle
@onready var node_label: Label = %Label
@onready var node_label_2: Label = %Label2

@export var index_door: = 0
@export var nb_keys_needed: = 0

@export var position_show: = Vector2(-11.0, -20.0)
@export var position_hide: = Vector2(-11.0, -6.0)

var nb_key: = 0
var player_in_range: = false

func _ready() -> void :
	var door_tile = node_map.local_to_map(global_position)
	global_position = node_map.map_to_local(door_tile)
	node_bulle.position = position_hide
	node_bulle.scale = Vector2.ZERO
	node_bulle.visible = false
	node_label.text = str(nb_key)
	node_label_2.text = str(nb_keys_needed)

func open_door() -> void :
	print(self.name + "Open")
	var tile_to_erase: = node_map.local_to_map(global_position)
	node_tile_map_layer_wall.erase_cell(tile_to_erase)
	if index_door == 2:
		EVENTS.emit_signal("door2")
	queue_free()

func gain_key() -> void :
	nb_key += 1
	node_label.text = str(nb_key)
	if nb_key >= nb_keys_needed:
		open_door()

func _on_area_entered(area: Area2D) -> void :
	if area is Keys:
		gain_key()

func _on_detect_show_area_entered(area: Area2D) -> void :
	if area is Player:
		player_in_range = true
		node_bulle.visible = true
		var tween = create_tween().set_parallel()
		tween.tween_property(node_bulle, "position", position_show, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
		tween.tween_property(node_bulle, "scale", Vector2.ONE, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)


func _on_detect_show_area_exited(area: Area2D) -> void :
	if area is Player:
		player_in_range = false
		var tween = create_tween().set_parallel()
		tween.tween_property(node_bulle, "position", position_hide, 0.3).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
		tween.tween_property(node_bulle, "scale", Vector2.ZERO, 0.3).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
		tween.connect("finished", _on_tween_finished)

func _on_tween_finished() -> void :
	if player_in_range == false:
		node_bulle.visible = false
