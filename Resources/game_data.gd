extends Resource
class_name GameData

const defaut_highscore: = 1342.0

var first_launch = true
var nb_wall_hit = 0
var nb_fall = 0
var nb_moves = 0
var nb_dashs = 0
var run_time: = 0.0
var previous_best_time: = 0.0

@export var version: float = 1.1

@export var best_global_time: float = defaut_highscore
@export var best_global_time_superdash: float = defaut_highscore
@export var best_moves_count: int = 1000

@export var star1: bool = false
@export var star2: bool = false
@export var star3: bool = false
@export var star4: bool = false
@export var star5: bool = false
@export var star6: bool = false

@export var challenge1: bool = false
@export var challenge2: bool = false
@export var challenge3: bool = false
@export var challenge4: bool = false
@export var challenge5: bool = false
@export var challenge6: bool = false

@export var option1: bool = true
@export var option2: bool = true
@export var option3: bool = false
@export var option4: bool = false
@export var option5: bool = false
@export var option6: bool = true
@export var option7: bool = false
@export var option8: bool = false
@export var option_music: int = -12
@export var option_sound: int = -9
@export var option_fullscreen: bool = true
@export var option_superdash: bool = true
@export var option_langue: int = 0
