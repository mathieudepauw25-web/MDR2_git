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
	
	# On délègue le travail réseau à l'ApiManager en lui passant notre fonction de retour
	ApiManager.make_request("/api/publish", HTTPClient.METHOD_POST, file_content, _on_publish_response)

# Cette fonction sera appelée par l'ApiManager quand le serveur répondra
func _on_publish_response(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	if result != HTTPRequest.RESULT_SUCCESS:
		printerr("PublishManager Error: Connection failed. Is server running?")
		return
		
	if response_code == 200 or response_code == 201:
		print("PublishManager Success: Level published successfully!")
	else:
		printerr("PublishManager Error: Server returned code ", response_code)
		var response_message = body.get_string_from_utf8()
		if response_message != "":
			printerr("Server details: ", response_message)
