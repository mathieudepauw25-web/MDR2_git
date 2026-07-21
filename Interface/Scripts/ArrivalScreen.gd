extends Control
class_name ArrivalScreen

@onready var node_color_rect_up: ColorRect = %ColorRect_UP
@onready var node_color_rect_down: ColorRect = %ColorRect_Down
@onready var node_timer_arrival: TimerArrival = %TimerArrival
@onready var node_timer_best: TimerBest = %TimerBest
@onready var node_panel_leaderboard_arrival: Panel = %Panel_leaderboard_arrival
@onready var node_v_box_container: VBoxContainer = %VBoxContainer
@onready var stats_mineur: Control = %Stats_mineur
@onready var timer_button: Timer = $Timer_Button

@onready var node_nb_move: Label = %NbMove
@onready var node_nb_dash: Label = %NbDash
@onready var node_nb_pok: Label = %NbPok
@onready var node_nb_fall: Label = %NbFall

@onready var node_buttons: Node2D = $CanvasLayer / Buttons
@onready var node_restart: Button = %Restart
@onready var node_title_screen: Button = %"Title screen"
@onready var node_top_10: Button = %Top10
@onready var label_new_record: Label = $CanvasLayer / Timer / Label_new_record


@export var LeaderboardUsersScore1: PackedScene = preload("res://Interface/LaderboardLine.tscn")
@export var TrophyResume: PackedScene = preload("res://Interface/TrophyResume.tscn")

var showing_leaderboard: = false
var top10_world: = false

func _ready() -> void :
	node_color_rect_up.position.y -= 100.0
	node_color_rect_down.position.y += 100.0
	node_timer_arrival.scale = Vector2.ZERO
	node_timer_best.visible = false

	node_nb_move.text = str(GAMES.game_data.nb_moves)
	node_nb_dash.text = str(GAMES.game_data.nb_dashs)
	node_nb_pok.text = str(GAMES.game_data.nb_wall_hit)
	node_nb_fall.text = str(GAMES.game_data.nb_fall)

	Steam.leaderboard_scores_downloaded.connect(_on_leaderboard_scores_downloaded)
	EVENTS.trophy_resume_free.connect(_on_trophy_resume_free)
	$Suspence.play()

	update_text()

	if GAMES.SteamisRunning:
		if GAMES.superdash_run:
			GAMES.BoardHandleName = "SuperDashHighscore"
		GAMES.find_leaderboard(GAMES.BoardHandleName)

	var tween = create_tween().set_parallel()
	tween.tween_property(node_color_rect_up, "position", Vector2(0.0, -22.0), 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(node_color_rect_down, "position", Vector2(0.0, 151.0), 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(node_timer_arrival, "scale", Vector2(2.0, 2.0), 3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)


func _input(event: InputEvent) -> void :
	if event.is_action_pressed("move_down"): $SFX / UI_menu_up_down.play(0.02)
	if event.is_action_pressed("move_up"): $SFX / UI_menu_up_down.play(0.02)
	if event.is_action_pressed("ui_accept"): $SFX / UI_menu_click.play()
	if event.is_action_pressed("move_right"): change_scope_top10()
	if event.is_action_pressed("move_left"): change_scope_top10()
	if node_panel_leaderboard_arrival.visible:
		if event.is_action_pressed("dash_right"):
			_on_top_10_pressed()
			$SFX / UI_cancel.play()
		if event.is_action_pressed("escape"):
			_on_top_10_pressed()
			$SFX / UI_cancel.play()


func change_scope_top10() -> void :
	if showing_leaderboard == false: return
	top10_world = !top10_world
	var txt_top10 = "world" if top10_world else "friends"
	$CanvasLayer / Panel_leaderboard_arrival / Panel_world / Label_world.text = txt_top10
	$SFX / UI_page_turn.play()
	update_text()

	var scoreline = node_v_box_container.get_children()
	for n in scoreline:

		n.queue_free()
	showing_leaderboard = false
	_on_top_10_pressed()

func update_text() -> void :
	var text: = "not determined"
	if top10_world:
		if GAMES.game_data.option_langue == 0: text = "world"
		if GAMES.game_data.option_langue == 1: text = "monde"
	else:
		if GAMES.game_data.option_langue == 0: text = "friends"
		if GAMES.game_data.option_langue == 1: text = "amis"
	$CanvasLayer / Panel_leaderboard_arrival / Panel_world / Label_world.text = text

func _on_timer_best_timeout() -> void :
	node_timer_best.update()
	node_timer_best.visible = true

	stats_mineur.visible = true

	var best_run_time: float = GAMES.game_data.best_global_time
	if GAMES.superdash_run:
		best_run_time = GAMES.game_data.best_global_time_superdash

	if GAMES.game_data.run_time <= best_run_time:
		label_new_record.visible = true

	var trophy_resume = TrophyResume.instantiate()
	add_child(trophy_resume)



func start_timer_button() -> void :
	timer_button.start()


func _on_timer_button_timeout() -> void :
	var restart_global_initial_position = node_restart.global_position
	var title_screen_global_initial_position = node_title_screen.global_position
	var top_10_global_initial_position = node_top_10.global_position
	node_restart.global_position += Vector2(300.0, 0.0)
	node_top_10.global_position += Vector2(600.0, 0.0)
	node_title_screen.global_position += Vector2(900.0, 0.0)
	node_buttons.visible = true

	var tween = create_tween().set_parallel()
	tween.tween_property(node_restart, "global_position", restart_global_initial_position, 0.8).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	tween.tween_property(node_title_screen, "global_position", title_screen_global_initial_position, 0.85).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	tween.tween_property(node_top_10, "global_position", top_10_global_initial_position, 0.9).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	tween.connect("finished", _on_tween_finished)


func _on_restart_pressed() -> void :
	get_tree().reload_current_scene()
	Engine.time_scale = 1

func _on_title_screen_pressed() -> void :
	GAMES.superdash_run = false
	get_tree().change_scene_to_file("res://TitleScreen/TitleScreen.tscn")

func _on_top_10_pressed() -> void :
	if showing_leaderboard:
		showing_leaderboard = false
		node_panel_leaderboard_arrival.visible = false
		$CanvasLayer / Buttons / Top10 / texture_deploy_top10.visible = false
		var scoreline = node_v_box_container.get_children()
		for n in scoreline:

			n.queue_free()

	else:
		if Steam.isSteamRunning():
			var entries_scop = Steam.LEADERBOARD_DATA_REQUEST_FRIENDS
			if top10_world: entries_scop = Steam.LEADERBOARD_DATA_REQUEST_GLOBAL
			Steam.downloadLeaderboardEntries(0, 10, entries_scop)
			node_panel_leaderboard_arrival.visible = true
			showing_leaderboard = true
			$CanvasLayer / Buttons / Top10 / texture_deploy_top10.visible = true

func _on_leaderboard_scores_downloaded(_handle, result):
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

func _on_tween_finished() -> void :
	node_restart.grab_focus()

func _on_trophy_resume_free() -> void :
	start_timer_button()
	$Final_time.play()
