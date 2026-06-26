extends Button
class_name SkinSlot

@onready var sprite: AnimatedSprite2D = $SpriteAnchor/AnimatedSprite2D
@onready var dark_filter: Panel = $FiltreSombre 
@onready var locked_banner: Label = $NameOrLocked
@onready var equipped_indicator: Panel = $Panel
@onready var locked_indicator: Sprite2D = $Croix

var skin_id: String = ""
var skin_name_text: String = "" 
var is_unlocked: bool = false

func _ready() -> void:
	pass

func setup(data: SkinData, unlocked: bool, is_equipped: bool = false) -> void:
	skin_name_text = data.skin_name 
	is_unlocked = unlocked
	equipped_indicator.visible = is_equipped
	if data.secret and not unlocked:
		skin_id = "Locked"
		sprite.animation = "Locked"
		sprite.frame = 0 
		dark_filter.visible = true
		locked_banner.text = "Locked"
		locked_indicator.show()
	else:
		skin_id = data.skin_id
		if sprite.sprite_frames and sprite.sprite_frames.has_animation(skin_id):
			sprite.animation = skin_id
			sprite.frame = 0 
		if is_unlocked:
			dark_filter.visible = false
			locked_banner.text = skin_name_text
			locked_indicator.hide()
		else:
			dark_filter.visible = true
			locked_banner.text = "Locked"
			locked_indicator.show()

func _on_mouse_entered() -> void:
	$%Move.play()
	if sprite.sprite_frames and sprite.sprite_frames.has_animation(skin_id):
		sprite.play(skin_id)
	locked_banner.text = skin_name_text

func _on_mouse_exited() -> void:
	if sprite.sprite_frames and sprite.sprite_frames.has_animation(skin_id):
		sprite.stop()
		sprite.frame = 0
	if is_unlocked:
		locked_banner.text = skin_name_text
	else:
		locked_banner.text = "Locked"

func _on_pressed() -> void:
	if is_unlocked:
		$%Select.play()
