extends Control

@onready var grid_container: GridContainer = $CanvasLayer/ScrollContainer/GridContainer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("escape"):
		if grid_container.visible == true:
			grid_container.visible = false


func _on_quest_pack_pressed() -> void:
	if grid_container.visible == true:
		grid_container.visible = false
	else :
		grid_container.visible = true
