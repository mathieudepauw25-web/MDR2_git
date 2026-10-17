extends Node

var steam_initialized: bool = false
var current_ticket_id: int = 0


func _ready() -> void:
	initialize_steam()


func _process(_delta: float) -> void:
	if steam_initialized:
		Steam.run_callbacks()


func initialize_steam() -> bool:
	if steam_initialized:
		return true

	if not Steam.isSteamRunning():
		steam_initialized = false
		print("STEAM_MANAGER: Steam unavailable. Offline mode.")
		return false

	var init_response: Dictionary = Steam.steamInitEx()

	if init_response.get("status", 1) != 0:
		steam_initialized = false
		print("STEAM_MANAGER: Initialization failed. Offline mode.")
		return false

	steam_initialized = true

	print("STEAM_MANAGER: Steam initialized successfully.")
	print("Player: ", Steam.getPersonaName())
	print("SteamID: ", Steam.getSteamID())

	return true


func generate_ticket() -> String:
	if not steam_initialized:
		print("STEAM_MANAGER: Cannot generate a ticket while offline.")
		return ""

	print("STEAM_MANAGER: Requesting authentication ticket...")

	var ticket_response: Dictionary = Steam.getAuthSessionTicket()

	if not ticket_response.has("id") or not ticket_response.has("buffer"):
		print("STEAM_MANAGER: Invalid ticket response.")
		return ""

	var ticket_buffer: PackedByteArray = ticket_response["buffer"]

	if ticket_buffer.is_empty():
		print("STEAM_MANAGER: Empty authentication ticket.")
		return ""

	current_ticket_id = ticket_response["id"]
	var ticket_hex: String = ticket_buffer.hex_encode()

	print("STEAM_MANAGER: Authentication ticket generated.")
	return ticket_hex
