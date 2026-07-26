extends Window

func _ready():
	add_theme_font_size_override("title_font_size", 3)
	add_theme_constant_override("resize_margin", 8)
	var style_border = StyleBoxFlat.new()
	style_border.bg_color = Color(0.102, 0.541, 0.176, 1.0)
	style_border.expand_margin_top = 8
	style_border.expand_margin_left = 1
	style_border.expand_margin_right = 1
	style_border.expand_margin_bottom = 1
	add_theme_stylebox_override("embedded_border", style_border)
	add_theme_constant_override("close_h_offset", 25)
	add_theme_constant_override("close_v_offset", 20)
