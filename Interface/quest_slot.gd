extends Button

func _ready():
	ajuster_taille_texte()

func ajuster_taille_texte():
	var font = get_theme_font("font")
	var taille_max := 26
	var taille_min := 10

	for taille in range(taille_max, taille_min - 1, -1):
		var largeur_texte = font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, taille).x
		
		if largeur_texte <= size.x - 20:
			add_theme_font_size_override("font_size", taille)
			return
