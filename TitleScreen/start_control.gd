extends Control

@onready var timer: Timer = $Timer




# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass





var tween: Tween
var FocusTimerCmampagne = false
func _on_start_campagne_focus_entered() -> void:
	$StartCampagne/CPUParticles2D.emitting = true
	$StartCampagne/CPUParticles2D2.emitting = true
func _on_start_campagne_focus_exited() -> void:
	$StartCampagne/CPUParticles2D.emitting = false
	$StartCampagne/CPUParticles2D2.emitting = false

func _on_start_level_editor_focus_entered() -> void:
	$StartLevelEditor/CPUParticles2D5.emitting = true
	$StartLevelEditor/CPUParticles2D6.emitting = true
func _on_start_level_editor_focus_exited() -> void:
	$StartLevelEditor/CPUParticles2D5.emitting = false
	$StartLevelEditor/CPUParticles2D6.emitting = false

func _on_start_online_level_focus_entered() -> void:
	$StartOnlineLevel/CPUParticles2D3.emitting = true
	$StartOnlineLevel/CPUParticles2D4.emitting = true
func _on_start_online_level_focus_exited() -> void:
	$StartOnlineLevel/CPUParticles2D3.emitting = false
	$StartOnlineLevel/CPUParticles2D4.emitting = false
