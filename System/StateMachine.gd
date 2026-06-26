extends State
class_name StateMachine

@onready var node_state_label: Label = %StateLabel

var current_state: Node = null
var previous_state: Node = null

signal state_changed(new_state)


func _ready() -> void :
    current_state = get_child(0)
    node_state_label.set_text(current_state.name)


func set_state(new_state) -> void :
    if new_state is String:
        new_state = get_node_or_null(new_state)
    if new_state == current_state: return

    current_state.state_exit()
    previous_state = current_state
    current_state = new_state
    current_state.state_enter()

    node_state_label.set_text(current_state.name)
    emit_signal("state_changed", current_state)

func get_state() -> Node:
    return current_state

func get_state_name() -> String:
    return current_state.name

func get_previous_state() -> Node:
    return previous_state
