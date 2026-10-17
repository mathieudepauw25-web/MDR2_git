extends Node

func publish_level(file_path: String) -> void:
	if file_path == "" or not FileAccess.file_exists(file_path):
		printerr("PUBLISH_MANAGER Error: File not found at ", file_path)
		return
		
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		printerr("PUBLISH_MANAGER Error: Could not read file.")
		return
		
	var file_content: String = file.get_as_text()
	file.close()
	
	print("PUBLISH_MANAGER: Sending ", file_path, " to server...")
	API_MANAGER.make_request("/api/publish", HTTPClient.METHOD_POST, file_content, _on_publish_response)

func _on_publish_response(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	if result != HTTPRequest.RESULT_SUCCESS:
		printerr("PUBLISH_MANAGER Error: Connection failed.")
		NOTIFICATION_MANAGER.show_message("Erreur Réseau", "Impossible de contacter le serveur.")
		return
		
	if response_code == 200 or response_code == 201:
		print("PUBLISH_MANAGER Success: Level published successfully!")
		NOTIFICATION_MANAGER.show_message("Succès", "Le niveau a été publié avec succès !")
	else:
		printerr("PUBLISH_MANAGER Error: Server returned code ", response_code)
		var response_message = body.get_string_from_utf8()
		NOTIFICATION_MANAGER.show_message("Erreur " + str(response_code), "Échec de la publication.\n" + response_message)
