extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("escape") and $ScrollContainer/ItemList/Quest_pack/CanvasLayer.visible == false:
		EVENTS.emit_signal("change_to_main_menu")
		get_parent().get_child(5).find_child("CanvasLayer").visible = true
		get_parent().get_child(5).find_child("CanvasLayer").find_child("MenuControl").find_child("Controls").grab_focus()
		queue_free()
