extends Node
class_name Game

const SAVE_DIR = "user://saves/"
const SAVE_FILE_NAME = "saveMDR.json"
const SECURITY_KEY = "1354RHEHR465ER"

@export var game_time_scale: float = 1
@warning_ignore("shadowed_global_identifier")
@export var LeaderboardUsersScore: PackedScene = preload("res://Interface/LaderboardLine.tscn")

var game_just_launch: = true
var game_data = GameData.new()
var SteamisRunning: = false
var AppId = "3404110"
var BoardHandleName: String = "Highscore"
var superdash_run = false

var all_trophy_unlock: = false
var all_star_unlock: = false

var trophy_already_unlock_1 = false
var trophy_already_unlock_2 = false
var trophy_already_unlock_3 = false
var trophy_already_unlock_4 = false
var trophy_already_unlock_5 = false
var trophy_already_unlock_6 = false

var handles_count: int = 0
var leaderboard_handles: Dictionary = {
	"Highscore": 0, 
	"SuperDashHighscore": 0, 
	"PlatformFlex": 0, 
}

func _init() -> void :
	OS.set_environment("SteamAppID", AppId)
	OS.set_environment("SteamGameID", AppId)

	Steam.leaderboard_find_result.connect(_on_leaderboard_find_result)


func _ready() -> void :
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

	Input.connect("joy_connection_changed", _on_joy_connection_changed)
	EVENTS.connect("save", _on_EVENTS_save)
	EVENTS.connect("player_move", _on_EVENTS_player_move)
	EVENTS.connect("player_dash", _on_EVENTS_player_dash)
	EVENTS.connect("player_pok", _on_EVENTS_player_pok)
	EVENTS.connect("player_fall", _on_EVENTS_player_fall)
	EVENTS.connect("get_leaderboard_top_world", _on_EVENTS_get_leaderboard_top_world)

	Steam.steamInit()
	SteamisRunning = Steam.isSteamRunning()

	handles_count = 0
	if SteamisRunning:
		var id = Steam.getSteamID()
		var steam_name = Steam.getFriendPersonaName(id)
		print("STEAM Username: ", str(steam_name))

		init_leaderboards_handles()

	verify_save_directory(SAVE_DIR)
	Engine.time_scale = game_time_scale
	load_data(SAVE_DIR + SAVE_FILE_NAME)
	load_controls()

	var mode_window = DisplayServer.WINDOW_MODE_WINDOWED
	if game_data.option_fullscreen: mode_window = DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN
	DisplayServer.window_set_mode(mode_window)

func _process(_delta: float) -> void :
	Steam.run_callbacks()

func _input(event: InputEvent) -> void :
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	if event is InputEventMouseMotion:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)




func init_leaderboards_handles() -> void :
	if handles_count > 2:
		init_leaderboards_handles_completed()
		return
	match handles_count:
		0: BoardHandleName = "Highscore"
		1: BoardHandleName = "SuperDashHighscore"
		2: BoardHandleName = "PlatformFlex"
	find_leaderboard(BoardHandleName)

func init_leaderboards_handles_completed() -> void :
	BoardHandleName = "Highscore"
	find_leaderboard(BoardHandleName)

func find_leaderboard(leaderboard_name: String = "Highscore") -> void :
	if SteamisRunning:
		Steam.findLeaderboard(leaderboard_name)
		print("find_leaderboard() : ", leaderboard_name)

func verify_save_directory(path: String) -> void :
	DirAccess.make_dir_absolute(path)

func save_data(path: String) -> void :
	print("save Data")
	var file = FileAccess.open_encrypted_with_pass(path, FileAccess.WRITE, SECURITY_KEY)

	if file == null:
		print(FileAccess.get_open_error())
		return

	var data: Dictionary = {
		"game_data": {
			"version": game_data.version, 
			"best_global_time": game_data.best_global_time, 
			"best_global_time_superdash": game_data.best_global_time_superdash, 
			"best_moves_count": game_data.best_moves_count, 
			"star1": game_data.star1, 
			"star2": game_data.star2, 
			"star3": game_data.star3, 
			"star4": game_data.star4, 
			"star5": game_data.star5, 
			"star6": game_data.star6, 
			"challenge1": game_data.challenge1, 
			"challenge2": game_data.challenge2, 
			"challenge3": game_data.challenge3, 
			"challenge4": game_data.challenge4, 
			"challenge5": game_data.challenge5, 
			"challenge6": game_data.challenge6, 
			"option1": game_data.option1, 
			"option2": game_data.option2, 
			"option3": game_data.option3, 
			"option4": game_data.option4, 
			"option5": game_data.option5, 
			"option6": game_data.option6, 
			"option7": game_data.option7, 
			"option8": game_data.option8, 
			"option_music": game_data.option_music, 
			"option_sound": game_data.option_sound, 
			"option_fullscreen": game_data.option_fullscreen, 
			"option_superdash": game_data.option_superdash, 
			"option_langue": game_data.option_langue, 
		}
	}

	var json_string = JSON.stringify(data, "\t")
	file.store_string(json_string)
	file.close()

func load_data(path: String) -> void :
	print("load Data")
	if FileAccess.file_exists(path):
		var file = FileAccess.open_encrypted_with_pass(path, FileAccess.READ, SECURITY_KEY)

		if file == null:
			print(FileAccess.get_open_error())
			return

		var content = file.get_as_text()
		file.close()

		var data = JSON.parse_string(content)
		if data == null:
			printerr("Cannot parse %s as a json_string: %s" % [path, content])
			return

		game_data = GameData.new()
		game_data.version = data.game_data.version

		game_data.best_global_time = data.game_data.best_global_time
		game_data.best_moves_count = data.game_data.best_moves_count
		if game_data.version >= 0.92:
			game_data.best_global_time_superdash = data.game_data.best_global_time_superdash

		game_data.star1 = data.game_data.star1
		game_data.star2 = data.game_data.star2
		game_data.star3 = data.game_data.star3
		game_data.star4 = data.game_data.star4
		game_data.star5 = data.game_data.star5
		game_data.star6 = data.game_data.star6

		game_data.challenge1 = data.game_data.challenge1
		game_data.challenge2 = data.game_data.challenge2
		game_data.challenge3 = data.game_data.challenge3
		game_data.challenge4 = data.game_data.challenge4
		game_data.challenge5 = data.game_data.challenge5
		game_data.challenge6 = data.game_data.challenge6

		game_data.option1 = data.game_data.option1
		game_data.option2 = data.game_data.option2
		game_data.option3 = data.game_data.option3
		game_data.option4 = data.game_data.option4
		game_data.option5 = data.game_data.option5
		game_data.option6 = data.game_data.option6
		game_data.option7 = data.game_data.option7
		game_data.option8 = data.game_data.option8

		if game_data.version >= 0.82:
			game_data.option_music = data.game_data.option_music
			game_data.option_sound = data.game_data.option_sound
			game_data.option_fullscreen = data.game_data.option_fullscreen
		else:
			game_data.version = 0.82

		if game_data.version >= 0.92:
			game_data.option_superdash = data.game_data.option_superdash
			game_data.option_langue = data.game_data.option_langue
		else:
			game_data.version = 0.92
	else:
		print("Cannot open non-existent file at %s!" % [path])
		print("--> create new one")
		save_data(SAVE_DIR + SAVE_FILE_NAME)

func check_trophy_already_unlock() -> void :
	trophy_already_unlock_1 = game_data.challenge1
	trophy_already_unlock_2 = game_data.challenge2
	trophy_already_unlock_3 = game_data.challenge3
	trophy_already_unlock_4 = game_data.challenge4
	trophy_already_unlock_5 = game_data.challenge5
	trophy_already_unlock_6 = game_data.challenge6


func update_best_time(global_time: float) -> void :
	if superdash_run:
		print("This was a SuperDash run")
		if global_time < game_data.best_global_time_superdash:
			game_data.best_global_time_superdash = global_time
			if SteamisRunning:
				Steam.uploadLeaderboardScore(int(game_data.best_global_time_superdash * 1000), true, PackedInt32Array(), GAMES.leaderboard_handles["SuperDashHighscore"])
				print("Upload best time on Steam for SUPERDASH")

		return

	if global_time < game_data.best_global_time:
		game_data.previous_best_time = game_data.best_global_time
		game_data.best_global_time = global_time

	if SteamisRunning:


		Steam.uploadLeaderboardScore(int(game_data.best_global_time * 1000), true, PackedInt32Array(), GAMES.leaderboard_handles["Highscore"])
		print("Upload best time on Steam for leaderboard : ", BoardHandleName)

	if floori(global_time) < 60 * 7: unlock_succes(1)
	if floori(global_time) < 60 * 3 + 30: unlock_succes(2)
	if floori(global_time) < 60 * 2: unlock_succes(3)
	if game_data.nb_dashs <= 0: unlock_succes(4)
	if game_data.nb_wall_hit <= 0: unlock_succes(5)
	if game_data.nb_fall <= 0: unlock_succes(6)

func unlock_succes(index_succes: int) -> void :
	match index_succes:
		1:
			game_data.challenge1 = true
			setAchievement("ACH_TIMER1")
		2:
			game_data.challenge2 = true
			setAchievement("ACH_TIMER2")
		3:
			game_data.challenge3 = true
			setAchievement("ACH_TIMER3")
		4:
			game_data.challenge4 = true
			setAchievement("ACH_NO_DASH")
		5:
			game_data.challenge5 = true
			setAchievement("ACH_NO_HIT")
		6:
			game_data.challenge6 = true
			setAchievement("ACH_NO_FALL")

func get_run_time(ref: int = 1) -> String:

	var value: = ""
	match ref:
		1:
			var Smin = game_data.run_time / 60
			value = str("%2d :" % Smin)
		2:
			var sec = fmod(game_data.run_time, 60)
			value = str("%02d :" % sec)
		3:
			var msec = fmod(game_data.run_time, 1) * 1000
			value = str("%02d" % msec)
	return value

func change_gameEngine_time(value: float = 0.1) -> void :
	Engine.time_scale += value
	print(Engine.time_scale)

func setAchievement(_ref_ach: String) -> void :
	pass
	'''if Steam.isSteamRunning() == false: return

	var status = Steam.getAchievement(_ref_ach)
	if status["achieved"]:
		print("Achievement: ", _ref_ach, " Already unlocked")
		return
	Steam.setAchievement(_ref_ach)
	Steam.storeStats()
	print("Unlocked achievement: ", _ref_ach)'''

func reset_run() -> void :
	BoardHandleName = "Highscore"
	game_data.nb_moves = 0
	game_data.nb_dashs = 0
	game_data.nb_wall_hit = 0
	game_data.nb_fall = 0
	superdash_run = false

func _on_EVENTS_player_move() -> void :
	game_data.nb_moves += 1

func _on_EVENTS_player_dash() -> void :
	game_data.nb_dashs += 1
	game_data.nb_moves += 1

func _on_EVENTS_player_pok() -> void :
	game_data.nb_wall_hit += 1

func _on_EVENTS_player_fall() -> void :
	game_data.nb_fall += 1

func _on_EVENTS_get_leaderboard_top_world() -> void :
	Steam.downloadLeaderboardEntries(0, 10, )

func _on_EVENTS_save() -> void :
	save_data(SAVE_DIR + SAVE_FILE_NAME)

func _on_leaderboard_find_result(handle: int, found: int) -> void :
	if found == 1:
		leaderboard_handles[BoardHandleName] = handle
		var _id = Steam.getSteamID()


		if handles_count < 2 + 1:
			handles_count += 1
			init_leaderboards_handles()
	else:
		print("No handle was found")

func _on_joy_connection_changed(_device: int, connected: bool) -> void :
	if connected:
		pass
	else:
		var nb_gamepad = Input.get_connected_joypads().size()
		if nb_gamepad <= 0:
			EVENTS.emit_signal("paused")

func load_controls() -> void:
	var config = ConfigFile.new()
	if config.load("user://controls.cfg") != OK:
		return 
	for action_id in config.get_section_keys("Controls"):
		var saved_event = config.get_value("Controls", action_id)
		InputMap.action_erase_events(action_id)
		InputMap.action_add_event(action_id, saved_event)
