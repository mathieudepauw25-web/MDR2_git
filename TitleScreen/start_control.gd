extends Control

@onready var campagne_panel: Panel = $StartCampagne/CampagnePanel
@onready var panel_online_level: Panel = $StartOnlineLevel/PanelOnlineLevel
@onready var panel_level_editor: Panel = $StartLevelEditor/PanelLevelEditor




# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	campagne_panel.visible = false
	panel_level_editor.visible = false
	panel_online_level.visible = false
	campagne_panel.z_index = -1
	panel_level_editor.z_index = -1
	panel_online_level.z_index = -1


var tween: Tween
func _on_start_campagne_focus_entered() -> void:
	campagne_panel.visible = true
	tween = create_tween()
	tween.tween_property(campagne_panel, "offset_transform_position_ratio", Vector2(1.05, 0), 0.2)
func _on_start_campagne_focus_exited() -> void:
	tween = create_tween()
	tween.tween_property(campagne_panel, "offset_transform_position_ratio", Vector2(0, 0), 0.1)
	await tween.finished
	campagne_panel.visible = false



func _on_start_level_editor_focus_entered() -> void:
	panel_level_editor.visible = true
	tween = create_tween()
	tween.tween_property(panel_level_editor, "offset_transform_position_ratio", Vector2(-1.08, 0), 0.2)
func _on_start_level_editor_focus_exited() -> void:
	tween = create_tween()
	tween.tween_property(panel_level_editor, "offset_transform_position_ratio", Vector2(0, 0), 0.1)
	await tween.finished
	panel_level_editor.visible = false



func _on_start_online_level_focus_entered() -> void:
	panel_online_level.visible = true
	tween = create_tween()
	tween.tween_property(panel_online_level, "offset_transform_position_ratio", Vector2(-1.08, 0), 0.2)
func _on_start_online_level_focus_exited() -> void:
	tween = create_tween()
	tween.tween_property(panel_online_level, "offset_transform_position_ratio", Vector2(0, 0), 0.1)
	await tween.finished
	panel_online_level.visible = false
