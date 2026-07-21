extends Panel
class_name LeaderboardUsersScore

func SetUpLeaderboardScore(rank, _name, score) -> void :
	var float_score: float = score / 1000.0






	$HBoxContainer / Rank.text = str(rank)
	$HBoxContainer / Name.text = str(_name)




	$HBoxContainer / Score / Min.text = get_string_timer_min(float_score)
	$HBoxContainer / Score / Sec.text = get_string_timer_sec(float_score)
	$HBoxContainer / Score / MSec.text = get_string_timer_msec(float_score)


func get_string_timer_min(score: float) -> String:
	var Smin = score / 60
	return "%2d : " % Smin

func get_string_timer_sec(score: float) -> String:
	var sec = fmod(score, 60)
	return "%02d : " % sec

func get_string_timer_msec(score: float) -> String:

	var msec = round(fmod(score, 1) * 1000)

	return "%03d" % msec
