extends Resource
class_name PlayerDataSkin

@export var unlocked_skins: Array[String] = ["Original"] 
@export var equipped_skin: String = "Original"


func save_data() -> void:
	ResourceSaver.save(self, "user://player_save.tres")
