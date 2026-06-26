extends State
class_name PlayerStateIdle

@onready var timer_inaction: Timer = $"../../inaction"

func state_enter() -> void :
    EVENTS.emit_signal("show_Dspot", owner.global_position)
    owner.snap_grid()
    owner.check_pressed_input()
    timer_inaction.start()

func state_exit() -> void :
    EVENTS.emit_signal("hide_Dspot")
    timer_inaction.stop()
