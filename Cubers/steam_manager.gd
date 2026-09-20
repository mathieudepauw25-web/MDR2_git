extends Node

func _ready() -> void:
	# Initialisation de l'API Steam
	var init_response: Dictionary = Steam.steamInitEx()
	
	if init_response["status"] > 0:
		printerr("GodotSteam Erreur: ", init_response["verbal"])
		return
		
	print("GodotSteam Succès ! Connecté en tant que : ", Steam.getPersonaName())
	print("SteamID du joueur : ", Steam.getSteamID())

func _process(_delta: float) -> void:
	# Contrairement aux autres Autoloads, Steam DOIT tourner en boucle 
	# pour écouter les réponses du serveur Steam (les callbacks).
	Steam.run_callbacks()


# On garde une trace de l'ID du ticket pour pouvoir l'annuler plus tard si besoin
var current_ticket_id: int = 0

func generer_ticket() -> String:
	print("SteamManager: Demande de ticket en cours...")
	
	# 1. On demande le ticket à Steam (retourne un dictionnaire avec "id" et "buffer")
	var ticket_response: Dictionary = Steam.getAuthSessionTicket()
	
	current_ticket_id = ticket_response["id"]
	var ticket_buffer: PackedByteArray = ticket_response["buffer"]
	
	# 2. On convertit les données brutes en texte hexadécimal
	var ticket_hex: String = ticket_buffer.hex_encode()
	
	print("SteamManager: Ticket généré avec succès !")
	print("Taille du ticket : ", ticket_hex.length(), " caractères.")
	
	# On retourne le ticket prêt à être envoyé par le réseau
	return ticket_hex
