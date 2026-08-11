extends Control

const EDIT_ACCESS_SCENE = preload("res://Larchet/Menus/LevelEditor/Edit_Access.tscn")
const LEVEL_EDITOR_SCENE = preload("res://Larchet/LevelMaker/Scenes/Level_Editor.tscn")

@export var dossier_niveaux: String = "res://Larchet/LevelMaker/Level_temp/"

@onready var btn_new: Button = $New 
@onready var btn_delete: Button = $Delete
@onready var lbl_delete: Label = $Delete/Label
@onready var hbox: HBoxContainer = $HBoxContainer

var for_delete: bool = false

func _ready() -> void:
	btn_new.pressed.connect(_on_btn_new_pressed)
	btn_delete.pressed.connect(_on_btn_delete_pressed)
	generer_liste_niveaux()

func generer_liste_niveaux() -> void:
	for enfant in hbox.get_children():
		enfant.queue_free()
	var dir = DirAccess.open(dossier_niveaux)
	if dir == null:
		return
	dir.list_dir_begin()
	var fichier_nom = dir.get_next()
	var compteur_id: int = 1
	while fichier_nom != "":
		if not dir.current_is_dir() and fichier_nom.ends_with(".json"):
			var chemin_complet = dossier_niveaux + "/" + fichier_nom
			_creer_bouton_niveau(chemin_complet, compteur_id)
			compteur_id += 1
		fichier_nom = dir.get_next()
	dir.list_dir_end()

func _creer_bouton_niveau(chemin_json: String, index_fallback: int) -> void:
	var map_data = JSONGestionnaire.charger_map(chemin_json)
	var nom_niveau = "Niveau " + str(index_fallback)
	if not map_data.is_empty() and map_data.has("global"):
		nom_niveau = str(map_data["global"].get("level_name", nom_niveau))
	var bouton_instance = EDIT_ACCESS_SCENE.instantiate() as Button
	hbox.add_child(bouton_instance)
	var label_enfant = bouton_instance.get_node_or_null("Label")
	if label_enfant != null:
		label_enfant.text = nom_niveau
	else:
		bouton_instance.text = nom_niveau
	bouton_instance.pressed.connect(func(): _on_level_button_pressed(chemin_json))

func _on_level_button_pressed(chemin_json: String) -> void:
	if for_delete:
		var err = DirAccess.remove_absolute(chemin_json)
		if err == OK:
			print("Niveau supprimé avec succès : ", chemin_json)
			generer_liste_niveaux() 
	else:
		_lancer_editeur(chemin_json)

func _on_btn_new_pressed() -> void:
	_lancer_editeur("")

func _lancer_editeur(chemin_json: String) -> void:
	var editeur_instance = LEVEL_EDITOR_SCENE.instantiate()
	get_tree().root.add_child(editeur_instance)
	var scene_menu = get_tree().current_scene
	if is_instance_valid(scene_menu):
		scene_menu.queue_free()
	get_tree().current_scene = editeur_instance
	if chemin_json != "" and editeur_instance.has_method("charger_editeur_depuis_json"):
		editeur_instance.charger_editeur_depuis_json(chemin_json)
	else:
		editeur_instance.current_level_id = -1
		editeur_instance.current_file_path = ""
		editeur_instance.current_level_name = ""

func _on_btn_delete_pressed() -> void:
	for_delete = !for_delete
	if for_delete:
		lbl_delete.text = "Delete"
	else:
		lbl_delete.text = "Select"
