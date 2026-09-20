extends Control

@onready var fond_gris: Panel = %FondGris
@onready var label_message: Label = %TexteMessage

func _ready() -> void:
	# On cache le pop-up au démarrage
	fond_gris.hide()

func show_message(_title: String, message: String) -> void:
	# On met à jour le texte et on affiche
	label_message.text = message
	fond_gris.show()
	
	# On crée un minuteur de 3 secondes, et on "await" (attend) la fin
	await get_tree().create_timer(3.0).timeout
	
	# Au bout de 3 secondes, le code reprend ici et on cache le message
	fond_gris.hide()
