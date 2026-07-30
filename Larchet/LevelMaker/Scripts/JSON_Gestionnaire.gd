extends Node
class_name JSONGestionnaire

static func sauvegarder_map(chemin_fichier: String, donnees: Dictionary) -> void:
	var dossier = chemin_fichier.get_base_dir()
	if not DirAccess.dir_exists_absolute(dossier):
		DirAccess.make_dir_recursive_absolute(dossier)
	var fichier = FileAccess.open(chemin_fichier, FileAccess.WRITE)
	if fichier == null:
		print("Erreur : Impossible d'écrire le fichier -> ", chemin_fichier)
		return
	var texte_json = JSON.stringify(donnees, "\t")
	fichier.store_string(texte_json)
	fichier.close()
	print("Niveau sauvegardé avec succès : ", chemin_fichier)

static func charger_map(chemin_fichier: String) -> Dictionary:
	if not FileAccess.file_exists(chemin_fichier):
		print("Erreur : Le fichier n'existe pas -> ", chemin_fichier)
		return {}
	var fichier = FileAccess.open(chemin_fichier, FileAccess.READ)
	var texte_json = fichier.get_as_text()
	fichier.close()
	var donnees = JSON.parse_string(texte_json)
	if donnees == null or typeof(donnees) != TYPE_DICTIONARY:
		print("Erreur : Fichier JSON corrompu ou invalide -> ", chemin_fichier)
		return {}
	return donnees
