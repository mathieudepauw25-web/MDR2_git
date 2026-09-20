extends Node

func _ready() -> void:
	# Dès que le jeu se lance et que Steam est prêt, on s'authentifie
	login_to_server()

func login_to_server() -> void:
	var ticket: String = SteamManager.generer_ticket()
	
	if ticket == "":
		printerr("UserManager: Impossible de générer le ticket Steam.")
		return
		
	# On prépare le paquet de données pour le serveur
	var data_dict = {
		"steam_id": str(Steam.getSteamID()),
		"ticket": ticket
	}
	
	var json_data: String = JSON.stringify(data_dict)
	print("UserManager: Envoi du ticket au serveur...")
	
	ApiManager.make_request("/api/auth", HTTPClient.METHOD_POST, json_data, _on_auth_response)

func _on_auth_response(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	if result != HTTPRequest.RESULT_SUCCESS:
		NotificationManager.show_message("Erreur", "Serveur injoignable.")
		return
		
	if response_code == 200:
		print("UserManager: Authentification validée par le serveur !")
		# Plus tard, c'est ici qu'on stockera le token de session du joueur
	else:
		var error_msg = body.get_string_from_utf8()
		printerr("UserManager: Échec de l'authentification. ", error_msg)
		NotificationManager.show_message("Erreur d'Auth", "La connexion a échoué.")
