extends Node

var catalog = preload("res://Larchet/Skins/Scripts/_Skin_List.tres")
var player_data: PlayerDataSkin


func _ready() -> void:
	if ResourceLoader.exists("user://player_save.tres"):
		player_data = load("user://player_save.tres") as PlayerDataSkin
	else:
		player_data = PlayerDataSkin.new()
		player_data.save_data()	


func unlock_skin(skin_id: String) -> void:
	if not player_data.unlocked_skins.has(skin_id):
		player_data.unlocked_skins.append(skin_id)
		player_data.save_data()

func equip_skin(skin_id: String) -> void:
	player_data.equipped_skin = skin_id
	player_data.save_data()
