extends Node

var is_authenticated: bool = false
var authentication_in_progress: bool = false


func _ready() -> void:
	# Automatically connect if Steam is available.
	if STEAM_MANAGER.steam_initialized:
		login_to_server()
	else:
		print("USER_MANAGER: Offline mode.")


func login_to_server() -> void:
	if authentication_in_progress:
		return

	# Retry Steam initialization when the user requests a connection.
	if not STEAM_MANAGER.initialize_steam():
		print("USER_MANAGER: Steam unavailable.")
		NOTIFICATION_MANAGER.show_message(
			"Connexion impossible",
			"Steam est indisponible. Ouvrez Steam puis réessayez."
		)
		return

	var ticket: String = STEAM_MANAGER.generate_ticket()

	if ticket.is_empty():
		print("USER_MANAGER: Failed to generate Steam ticket.")
		NOTIFICATION_MANAGER.show_message(
			"Erreur d'authentification",
			"Impossible de récupérer votre ticket Steam. Réessayez."
		)
		return

	var data: Dictionary = {
		"steam_id": str(Steam.getSteamID()),
		"ticket": ticket
	}

	var json_data: String = JSON.stringify(data)

	authentication_in_progress = true
	print("USER_MANAGER: Sending authentication request...")

	API_MANAGER.make_request(
		"/api/auth",
		HTTPClient.METHOD_POST,
		json_data,
		_on_auth_response
	)


func _on_auth_response(
	result: int,
	response_code: int,
	_headers: PackedStringArray,
	body: PackedByteArray
) -> void:
	authentication_in_progress = false

	if result != HTTPRequest.RESULT_SUCCESS:
		is_authenticated = false
		print("USER_MANAGER: Server connection failed.")

		NOTIFICATION_MANAGER.show_message(
			"Erreur réseau",
			"Impossible de contacter le serveur. Vérifiez votre connexion Internet."
		)
		return

	if response_code == 200 :
		is_authenticated = true
		print("USER_MANAGER: Authentication successful.")
		NOTIFICATION_MANAGER.show_message(
			"Connexion réussie",
			"Vous êtes connecté avec succès !"
		)
		return

	is_authenticated = false
	var error_message: String = body.get_string_from_utf8()
	print("USER_MANAGER: Authentication failed. ", response_code, " ", error_message)

	NOTIFICATION_MANAGER.show_message(
		"Échec de connexion",
		"La connexion a échoué. Vérifiez vos identifiants Steam ou réessayez plus tard."
	)
