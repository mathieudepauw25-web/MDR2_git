extends State
class_name PlayerStateSlide

func state_enter() -> void :
	%Slide.play()

func state_exit() -> void :
	%Slide.stop()
