extends Node

func publish_level(file_path: String) -> void:
	if file_path == "" or not FileAccess.file_exists(file_path):
		printerr("PublishManager Error: File not found at ", file_path)
		return
		
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		printerr("PublishManager Error: Could not read file.")
		return
		
	var file_content: String = file.get_as_text()
	file.close()
	
	print("PublishManager: Sending ", file_path, " to server...")
	ApiManager.make_request("/api/publish", HTTPClient.METHOD_POST, file_content, _on_publish_response)

func _on_publish_response(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	if result != HTTPRequest.RESULT_SUCCESS:
		printerr("PublishManager Error: Connection failed.")
		NotificationManager.show_message("Erreur Réseau", "Impossible de contacter le serveur.")
		return
		
	if response_code == 200 or response_code == 201:
		print("PublishManager Success: Level published successfully!")
		NotificationManager.show_message("Succès", "Le niveau a été publié avec succès !")
	else:
		printerr("PublishManager Error: Server returned code ", response_code)
		var response_message = body.get_string_from_utf8()
		NotificationManager.show_message("Erreur " + str(response_code), "Échec de la publication.\n" + response_message)
