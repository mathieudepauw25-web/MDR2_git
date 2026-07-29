extends Area2D
class_name Hidden

@onready var sprite: Sprite2D = $Sprite2D
var active_tween: Tween

func _ready() -> void:
	EVENTS.connect("hidden_tiles", _on_EVENTS_hidden_tiles)
	call_deferred("_request_skin")

func _request_skin() -> void:
	var editor = get_tree().current_scene 
	if editor and editor.has_method("apply_skin_to_hidden"):
		editor.apply_skin_to_hidden(self)

func pop() -> void:
	EVENTS.emit_signal("create_floor_tile", global_position)
	if active_tween and active_tween.is_valid():
		active_tween.kill()
	active_tween = create_tween()
	active_tween.tween_property(sprite, "scale", Vector2.ONE, 0.25).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)

func depop() -> void:
	EVENTS.emit_signal("erase_floor_tile", global_position)
	if active_tween and active_tween.is_valid():
		active_tween.kill()
	active_tween = create_tween()
	active_tween.tween_property(sprite, "scale", Vector2.ZERO, 0.25).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BOUNCE)

func _on_area_entered(area: Area2D) -> void:
	if area is Player:
		pop()

func _on_area_exited(area: Area2D) -> void:
	if area is Player:
		depop()

func _on_EVENTS_hidden_tiles(reveal: bool = false) -> void:
	if reveal: pop()
	else: depop()

func set_skin(base_texture: Texture2D, atlas_coords: Vector2i) -> void:
	var atlas = AtlasTexture.new()
	atlas.atlas = base_texture
	var start_x = atlas_coords.x * 16
	var start_y = atlas_coords.y * 16 -1
	atlas.region = Rect2(start_x, start_y, 17, 17)
	sprite.texture = atlas
