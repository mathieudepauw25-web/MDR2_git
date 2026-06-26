extends Node

var music_player: AudioStreamPlayer
var sfx_player: AudioStreamPlayer


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	music_player = AudioStreamPlayer.new()
	add_child(music_player)
	music_player.bus = "Master"
	sfx_player = AudioStreamPlayer.new()
	add_child(sfx_player)
	sfx_player.bus = "Master"

func play_music(audio_stream: AudioStream) -> void:
	if music_player.stream == audio_stream and music_player.playing:
		return
	music_player.stream = audio_stream
	music_player.play()

func stop_music() -> void:
	music_player.stop()

func play_sfx(audio_stream: AudioStream) -> void:
	sfx_player.stream = audio_stream
	sfx_player.play()
	
	
	
