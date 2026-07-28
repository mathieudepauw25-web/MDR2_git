extends Control

@onready var campagne_panel: Panel = $StartCampagne/CampagnePanel
@onready var panel_online_level: Panel = $StartOnlineLevel/PanelOnlineLevel
@onready var panel_level_editor: Panel = $StartLevelEditor/PanelLevelEditor
@onready var timer: Timer = $Timer




# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	campagne_panel.visible = false
	panel_level_editor.visible = false
	panel_online_level.visible = false





var tween: Tween
var FocusTimerCmampagne = false
func _on_start_campagne_focus_entered() -> void:
	campagne_panel.z_index = -1
	$StartCampagne.z_index = 1
	timer.stop()
	FocusTimerCmampagne = true
	$StartCampagne/CPUParticles2D.emitting = true
	$StartCampagne/CPUParticles2D2.emitting = true
	campagne_panel.visible = true
	tween = create_tween()
	tween.tween_property(campagne_panel, "offset_transform_position_ratio", Vector2(0.06, 0), 0.2)
	timer.start()
	await timer.timeout
	if FocusTimerCmampagne == true:
		tween = create_tween()
		tween.tween_property(campagne_panel, "offset_transform_position_ratio", Vector2(0.87, 0), 0.2)
func _on_start_campagne_focus_exited() -> void:
	FocusTimerCmampagne = false
	$StartCampagne/CPUParticles2D.emitting = false
	$StartCampagne/CPUParticles2D2.emitting = false
	tween = create_tween()
	tween.tween_property(campagne_panel, "offset_transform_position_ratio", Vector2(0, 0), 0.1)
	await tween.finished
	campagne_panel.visible = false
	$StartCampagne.z_index = -3
	campagne_panel.z_index = 0


var FocusTimerLevelEditor = false
func _on_start_level_editor_focus_entered() -> void:
	panel_level_editor.z_index = -1
	$StartLevelEditor.z_index = 1
	timer.stop()
	FocusTimerLevelEditor = true
	$StartLevelEditor/PanelLevelEditor/CPUParticles2D5.emitting = true
	$StartLevelEditor/PanelLevelEditor/CPUParticles2D6.emitting = true
	panel_level_editor.visible = true
	tween = create_tween()
	tween.tween_property(panel_level_editor, "offset_transform_position_ratio", Vector2(-0.08, 0), 0.2)
	timer.start()
	await timer.timeout
	if FocusTimerLevelEditor == true:
		tween = create_tween()
		tween.tween_property(panel_level_editor, "offset_transform_position_ratio", Vector2(-0.97, 0), 0.2)
func _on_start_level_editor_focus_exited() -> void:
	FocusTimerLevelEditor = false

	$StartLevelEditor/PanelLevelEditor/CPUParticles2D5.emitting = false
	$StartLevelEditor/PanelLevelEditor/CPUParticles2D6.emitting = false
	tween = create_tween()
	tween.tween_property(panel_level_editor, "offset_transform_position_ratio", Vector2(0, 0), 0.1)
	await tween.finished
	panel_level_editor.visible = false
	$StartLevelEditor.z_index = -3
	panel_level_editor.z_index = 0


var FocusTimerOnlineLevel = false
func _on_start_online_level_focus_entered() -> void:
	panel_online_level.z_index = -1
	$StartOnlineLevel.z_index = 1
	timer.stop()
	FocusTimerOnlineLevel = true
	$StartOnlineLevel/CPUParticles2D3.emitting = true
	$StartOnlineLevel/CPUParticles2D4.emitting = true
	panel_online_level.visible = true
	tween = create_tween()
	tween.tween_property(panel_online_level, "offset_transform_position_ratio", Vector2(-0.08, 0), 0.2)
	timer.start()
	await timer.timeout
	if FocusTimerOnlineLevel == true:
		tween = create_tween()
		tween.tween_property(panel_online_level, "offset_transform_position_ratio", Vector2(-0.97, 0), 0.2)
func _on_start_online_level_focus_exited() -> void:
	FocusTimerOnlineLevel = false

	$StartOnlineLevel/CPUParticles2D3.emitting = false
	$StartOnlineLevel/CPUParticles2D4.emitting = false
	tween = create_tween()
	tween.tween_property(panel_online_level, "offset_transform_position_ratio", Vector2(0, 0), 0.1)
	await tween.finished
	panel_online_level.visible = false
	$StartOnlineLevel.z_index = -3
	panel_online_level.z_index = 0
