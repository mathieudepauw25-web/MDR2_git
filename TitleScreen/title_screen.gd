extends Node2D
class_name TitleScreen

@onready var button_focus: Button = %Start
@onready var node_v_box_container: VBoxContainer = %VBoxContainer
@onready var node_panel_leaderboard_arrival: Panel = %Panel_leaderboard_arrival
@onready var node_path_follow_2d: PathFollow2D = $Path2D / PathFollow2D
@onready var node_container_trophy: HBoxContainer = $CanvasLayer / HBoxContainer_trophy
@onready var node_ui_menu_up_down: AudioStreamPlayer = $SFX / UI_menu_up_down
@onready var node_ui_menu_click: AudioStreamPlayer = $SFX / UI_menu_click
@onready var panel_options_2: Control = $CanvasLayer / HBoxContainer_MENU / VBoxContainer_menu / Panel_options2


@export var LeaderboardUsersScore1: PackedScene = preload("res://Interface/LaderboardLine.tscn")

var showing_leaderboard: = false
var camera_speed: = 0.01
var top10_world: = false

const MAIN_THEME = preload("res://Audio/Music/Sketchbook 2024-10-14.ogg")

func _ready() -> void :
	GAMES.superdash_run = false
	if GAMES.SteamisRunning:
		GAMES.find_leaderboard("Highscore")
	EVENTS.connect("close_option", _on_EVENTS_close_option)
	EVENTS.connect("save", update_text)
	Engine.time_scale = 1
	EVENTS.emit_signal("starting")
	EVENTS.emit_signal("door2")
	#$CanvasLayer / TimerBest.visible = true
	$CanvasLayer / Label_version.text = str(ProjectSettings.get_setting("application/config/version"))
	check_completion()
	update_text()
	if GAMES.all_trophy_unlock:
		$CanvasLayer / HBoxContainer_MENU / VBoxContainer_menu / Map.visible = true

	if (GAMES.game_data.best_global_time >= GAMES.game_data.defaut_highscore
	and GAMES.game_just_launch == true):
		_on_start_pressed()

	if GAMES.game_data.best_global_time_superdash < GAMES.game_data.defaut_highscore:
		$CanvasLayer / TimerBest_superdash.visible = true
	else:
		$CanvasLayer / TimerBest_superdash.visible = false

	GAMES.game_just_launch = false
	button_focus.grab_focus()
	EVENTS.emit_signal("update_star_data")
	Steam.leaderboard_scores_downloaded.connect(_on_leaderboard_scores_downloaded)

	AUDIOMANAGER.play_music(MAIN_THEME)
	AUDIOMANAGER.music_player.volume_db = -30
	AudioServer.set_bus_effect_enabled(1, 0, false)

func _process(delta: float) -> void :
	node_path_follow_2d.progress_ratio += delta * camera_speed
	if $BGM.volume_db < 0:
		$BGM.volume_db += 0.2

func _input(event: InputEvent) -> void :

	if not Input.is_joy_known(event.get_device()):

		return
	if event is InputEventJoypadMotion:
		if event.axis_value < 0 && event.axis_value > -1: return
		if event.axis_value > 0 && event.axis_value < 1: return
	if $CanvasLayer.visible == true:
		if event.is_action_pressed("move_down"): node_ui_menu_up_down.play(0.02)
		if event.is_action_pressed("move_up"): node_ui_menu_up_down.play(0.02)
		if event.is_action_pressed("ui_accept"): node_ui_menu_click.play()
		if node_panel_leaderboard_arrival.visible:
			if event.is_action_pressed("move_right"): change_scope_top10()
			if event.is_action_pressed("move_left"): change_scope_top10()
			if event.is_action_pressed("dash_right"):
				_on_leaderboard_pressed()
				$SFX / UI_cancel.play()
			if event.is_action_pressed("escape"):
				_on_leaderboard_pressed()
				$SFX / UI_cancel.play()
	if $MapViewControl.visible == true:
		if event.is_action_pressed("move_down"): pass
		if event.is_action_pressed("move_up"): pass
		if event.is_action_pressed("dash_right"): back_to_title_screen()
		if event.is_action_pressed("escape"): back_to_title_screen()

func check_completion() -> void :
	var nb_trophy: = 0
	var nb_star: = 0

	if GAMES.game_data.challenge1: nb_trophy += 1
	if GAMES.game_data.challenge2: nb_trophy += 1
	if GAMES.game_data.challenge3: nb_trophy += 1
	if GAMES.game_data.challenge4: nb_trophy += 1
	if GAMES.game_data.challenge5: nb_trophy += 1
	if GAMES.game_data.challenge6: nb_trophy += 1
	if GAMES.game_data.star1: nb_star += 1
	if GAMES.game_data.star2: nb_star += 1
	if GAMES.game_data.star3: nb_star += 1
	if GAMES.game_data.star4: nb_star += 1
	if GAMES.game_data.star5: nb_star += 1
	if GAMES.game_data.star6: nb_star += 1

	if nb_trophy >= 6:
		GAMES.all_trophy_unlock = true
	if nb_star >= 6:
		GAMES.all_star_unlock = true

func change_scope_top10() -> void :
	if showing_leaderboard == false: return
	top10_world = !top10_world
	update_text()
	$SFX / UI_page_turn.play()

	var scoreline = node_v_box_container.get_children()
	for n in scoreline:

		n.queue_free()
	showing_leaderboard = false
	_on_leaderboard_pressed()

func update_text() -> void :
	var text: = "not determined"
	if top10_world:
		if GAMES.game_data.option_langue == 0: text = "world"
		if GAMES.game_data.option_langue == 1: text = "monde"
	else:
		if GAMES.game_data.option_langue == 0: text = "friends"
		if GAMES.game_data.option_langue == 1: text = "amis"
	$CanvasLayer / HBoxContainer_MENU / Panel_leaderboard_arrival / Panel_world / Label_world.text = text

func _on_start_pressed() -> void :
	$CanvasLayer.visible = false
	var target = $Path2D/PathFollow2D/Camera2D 
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_EXPO)
	tween.tween_property(target, "zoom", Vector2(0.1, 0.1), 02)
	tween.tween_property(target, "zoom", Vector2(50,50), 25)
	await get_tree().create_timer(2).timeout
	get_tree().change_scene_to_file("res://World/World.tscn")
	Engine.time_scale = 1

func _on_leaderboard_pressed() -> void :
	if showing_leaderboard:
		showing_leaderboard = false
		node_panel_leaderboard_arrival.visible = false
		node_container_trophy.visible = true
		$CanvasLayer / HBoxContainer_MENU / VBoxContainer_menu / Leaderboard / texture_deploy_top10.visible = false
		var scoreline = node_v_box_container.get_children()
		for n in scoreline:

			n.queue_free()
	else:
		if Steam.isSteamRunning():
			var entries_scop = Steam.LEADERBOARD_DATA_REQUEST_FRIENDS
			if top10_world: entries_scop = Steam.LEADERBOARD_DATA_REQUEST_GLOBAL
			Steam.downloadLeaderboardEntries(0, 10, entries_scop)

			node_panel_leaderboard_arrival.visible = true
			node_container_trophy.visible = false
			showing_leaderboard = true
			$CanvasLayer / HBoxContainer_MENU / VBoxContainer_menu / Leaderboard / texture_deploy_top10.visible = true

func _on_map_pressed() -> void :
	$CanvasLayer.visible = false
	$MapViewControl.visible = true
	$Path2D / PathFollow2D / Camera2D.enabled = false
	$Camera_mapfree.enabled = true
	$World / MAP / tileMapLayer_hidden.visible = true
	EVENTS.emit_signal("hidden_tiles", true)
	EVENTS.emit_signal("close_option")
	$AudioListener2D.clear_current()

	var nb_gamepad = Input.get_connected_joypads().size()
	if nb_gamepad > 0:
		$MapViewControl / Icon_Gamepad.visible = true
		$MapViewControl / Icon_Keyboard.visible = false

func back_to_title_screen() -> void :
	$MapViewControl.visible = false
	$CanvasLayer.visible = true
	$Path2D / PathFollow2D / Camera2D.enabled = true
	$Camera_mapfree.enabled = false
	$World / MAP / tileMapLayer_hidden.visible = false
	EVENTS.emit_signal("hidden_tiles", false)
	$AudioListener2D.make_current()
	$CanvasLayer / HBoxContainer_MENU / VBoxContainer_menu / Map.grab_focus()
	$MapViewControl / Icon_Keyboard.visible = true
	$MapViewControl / Icon_Gamepad.visible = false
	$World / Grid.visible = false

func _on_options_pressed(forced_close: bool = false) -> void :
	panel_options_2.visible = !panel_options_2.visible
	if forced_close: panel_options_2.visible = false
	$CanvasLayer / HBoxContainer_MENU / VBoxContainer_menu / Options / texture_deploy_option.visible = panel_options_2.visible

func _on_quit_pressed() -> void :
	get_tree().quit()

func _on_leaderboard_scores_downloaded(_message, _handle, result):
	var compteur: int = 0
	for r in result:
		var UserScore = LeaderboardUsersScore1.instantiate()
		var rank = r.global_rank
		var _name = Steam.getFriendPersonaName(r.steam_id)
		var score = r.score
		UserScore.SetUpLeaderboardScore(rank, _name, score)
		node_v_box_container.add_child(UserScore)
		compteur += 1
		if compteur >= 10: return

func _on_EVENTS_close_option() -> void :
	_on_options_pressed(true)
	$CanvasLayer / HBoxContainer_MENU / VBoxContainer_menu / Options.grab_focus()


func _on_start_focus_entered() -> void :
	pass

##################### Mes fonctions #####################

func _on_skins_pressed() -> void:
	get_tree().change_scene_to_file("res://Larchet/Menus/SkinsPage/Skins.tscn")

func _on_controls_pressed() -> void:
	get_tree().change_scene_to_file("res://Larchet/Menus/ControlsPage/Scenes/Controls.tscn")
