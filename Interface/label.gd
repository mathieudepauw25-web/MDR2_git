extends Label

@export var max_font_size := 26
@export var min_font_size := 10

func _ready() -> void:
	ajuster_texte()

func ajuster_texte() -> void:
	var font := get_theme_font("font")
	var largeur_max := size.x

	for taille in range(max_font_size, min_font_size - 1, -1):
		var largeur := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, taille).x

		if largeur <= largeur_max:
			add_theme_font_size_override("font_size", taille)
			return
