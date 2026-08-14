extends CanvasLayer

@onready var glitch_indicator: Panel = $Glitchs/Glitch_Indicator
@onready var glitch_description: PanelContainer = $Glitchs/Description
@onready var label_description: Label = $Glitchs/Description/Label

func _ready() -> void:
	glitch_description.hide()
	if not glitch_indicator.mouse_entered.is_connected(_on_glitch_indicator_mouse_entered):
		glitch_indicator.mouse_entered.connect(_on_glitch_indicator_mouse_entered)
	if not glitch_indicator.mouse_exited.is_connected(_on_glitch_indicator_mouse_exited):
		glitch_indicator.mouse_exited.connect(_on_glitch_indicator_mouse_exited)

func _on_glitch_indicator_mouse_entered() -> void:
	glitch_description.show()

func _on_glitch_indicator_mouse_exited() -> void:
	glitch_description.hide()
