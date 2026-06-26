extends Button
class_name ControlSlot

@onready var label_action: Label = $Name
@onready var label_key: Label = $Button

var action_id: String = ""


func setup(p_action_id: String, p_action_name: String, p_current_key: String) -> void:
	action_id = p_action_id
	label_action.text = p_action_name
	label_key.text = p_current_key

func update_key_text(new_text: String) -> void:
	label_key.text = new_text

func _on_hover() -> void:
	$%Move.play()
