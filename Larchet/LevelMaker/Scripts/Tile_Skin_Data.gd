class_name TileSkinData

enum Brush {GRASS, WALL, ICE}

const WALL_SOURCE_ID: int = 0
const GRASS_SOURCE_ID: int = 1
const ICE_SOURCE_ID: int = 2

const SKINS: Dictionary = {
	"Normal": {
		"floor_dark" : [Vector3i(1,1,1), Vector3i(3,1,1), Vector3i(5,1,1), Vector3i(7,1,1)],
		"floor_light" : [Vector3i(1,5,1), Vector3i(3,5,1), Vector3i(5,5,1), Vector3i(7,5,1)],
		"wall_normal" : [Vector3i(0,1,0), Vector3i(2,1,0)],
		"wall_full" : [Vector3i(6,3,0), Vector3i(7,3,0), Vector3i(8,3,0)],
		"ice" : [Vector3i(0,1,2)],
		"right_ice_ice" : [Vector3i(0,1,2)],
		"up_ice_normal_ice" : [Vector3i(0,0,2)],
		"up_ice_E_ice" : [Vector3i(1,0,2)],
		"water_right_full" : [Vector3i(0,2,3)],
		"water_right_mini" : [Vector3i(0,3,3)],
		"water_right_Eright_grass" : [Vector3i(0,4,3)],
		"water_right_Eright_wall" : [Vector3i(1,4,3)],
		"water_down_down_grass" : [Vector3i(0,0,3), Vector3i(1,0,3), Vector3i(2,0,3), Vector3i(3,0,3)],
		"water_down_down_wall" : [Vector3i(0,1,3), Vector3i(1,1,3), Vector3i(2,1,3), Vector3i(3,1,3)],
		"water_left_full" : [Vector3i(2,2,3)],
		"water_left_mini" : [Vector3i(2,3,3)],
		"water_left_Eleft" : [Vector3i(2,4,3)],
		"right_wall_normal" : [Vector3i(1,1,0), Vector3i(3,1,0)],
		"right_wall_Eright_wall" : [Vector3i(0,2,0)],
		"up_wall_Ewall" : [Vector3i(1,0,0), Vector3i(3,0,0)],
		"up_wall_wall" : [Vector3i(0,0,0), Vector3i(2,0,0), Vector3i(9,2,0)],
		"right_normal_dark" : [Vector3i(2,1,1), Vector3i(4,1,1), Vector3i(6,1,1), Vector3i(8,1,1)],
		"right_normal_light" : [Vector3i(2,5,1), Vector3i(4,5,1), Vector3i(6,5,1), Vector3i(8,5,1)],
		"up_normal_dark" : [Vector3i(1,0,1), Vector3i(3,0,1), Vector3i(5,0,1), Vector3i(7,0,1)],
		"up_normal_light" : [Vector3i(1,4,1), Vector3i(3,4,1), Vector3i(5,4,1), Vector3i(7,4,1)],
		"up_E_dark" : [Vector3i(2,0,1)],
		"up_E_light" : [Vector3i(2,4,1)]
	}
}

const grass_bitmask_repo: Dictionary = {
	0: [{"persp_down_water": { Vector2i(0,1) : "down_grass" }, "persp_left_water": { Vector2i(-1,0) : "mini", Vector2i(-1,1) : "Eleft" }, "persp_right": {Vector2i(1,0) : "normal", Vector2i(1,1) : "Eright_grass"}, "persp_up": { Vector2i(0,-1) : "normal", Vector2i(1,-1) : "E"}}],
	1: [{"persp_down_water": { Vector2i(0,1) : "down_grass"}, "persp_left_water": { Vector2i(-1,0) : "full", Vector2i(-1,1) : "Eleft" }, "persp_right": {Vector2i(1,0) : "normal", Vector2i(1,1) : "Eright_grass"}}],
	2: [{"persp_down_water": { Vector2i(0,1) : "down_grass" }, "persp_left_water": { Vector2i(-1,0) : "mini", Vector2i(-1,1) : "Eleft"}, "persp_up": "normal"}],
	3: [{"persp_down_water": { Vector2i(0,1) : "down_grass" }, "persp_left_water": { Vector2i(-1,0) : "full", Vector2i(-1,1) : "Eleft" }}],
	4: [{"persp_left_water": { Vector2i(-1,0) : "mini" }, "persp_right": "normal", "persp_up": { Vector2i(0,-1) : "normal", Vector2i(1,-1) : "E"}}],
	5: [{"persp_left_water": { Vector2i(-1,0) : "full" }, "persp_right": "normal"}],
	6: [{"persp_left_water": "mini", "persp_up": "normal"}],
	7: [{"persp_left_water": "full"}],
	8: [{"persp_down_water": { Vector2i(0,1) : "down_grass"}, "persp_right": {Vector2i(1,0) : "normal", Vector2i(1,1) : "Eright_grass"}, "persp_up": { Vector2i(0,-1) : "normal", Vector2i(1,-1) : "E"}}],
	9: [{"persp_down_water": { Vector2i(0,1) : "down_grass"}, "persp_right": {Vector2i(1,0) : "normal", Vector2i(1,1) : "Eright_grass"}}],
	10: [{"persp_down_water": "down_grass", "persp_up": "normal"}],
	11: [{"persp_down_water": "down_grass"}],
	12: [{"persp_right": "normal", "persp_up": { Vector2i(0,-1) : "normal", Vector2i(1,-1) : "E"}}],
	13: [{"persp_right": "normal"}],
	14: [{"persp_up": "normal"}]
}

const wall_bitmask_repo: Dictionary = {
	0: [{"main": "normal", "persp_down_water": "down_wall", "persp_left_water": { Vector2i(-1,0) : "mini", Vector2i(-1,1) : "Eleft" }, "persp_right_wall": { Vector2i(1,0) : "normal", Vector2i(1,1) : "Eright_wall" }, "persp_up_wall": {Vector2i(0, -1) : "wall", Vector2i(1,-1) : "Ewall"}}],
	1: [{"main": "normal", "persp_down_water": "down_wall", "persp_left_water": { Vector2i(-1,0) : "full", Vector2i(-1,1) : "Eleft" }, "persp_right_wall": { Vector2i(1,0) : "normal", Vector2i(1,1) : "Eright_wall" }, "persp_up_wall": {Vector2i(1,-1) : "Ewall"}}],
	2: [{"main": "normal", "persp_down_water": "down_wall", "persp_left_water": { Vector2i(-1,0) : "mini", Vector2i(-1,1) : "Eleft"}, "persp_up_wall": {Vector2i(0, -1) : "wall"}}],
	3: [{"main": "normal", "persp_down_water": "down_wall", "persp_left_water": { Vector2i(-1,0) : "full", Vector2i(-1,1) : "Eleft" }}],
	4: [{"main" : "full", "persp_left_water": { Vector2i(-1,0) : "mini" }, "persp_right_wall": "normal", "persp_up_wall": {Vector2i(0, -1) : "wall", Vector2i(1,-1) : "Ewall"}}],
	5: [{"main" : "full", "persp_left_water": { Vector2i(-1,0) : "full" }, "persp_right_wall": "normal", "persp_up_wall": {Vector2i(1,-1) : "Ewall"}}],
	6: [{"main" : "full", "persp_left_water": "mini", "persp_up_wall": {Vector2i(0, -1) : "wall"}}],
	7: [{"main" : "full", "persp_left_water": { Vector2i(-1,0) : "full"}}],
	8: [{"main": "normal", "persp_down_water": "down_wall", "persp_right_wall": { Vector2i(1,0) : "normal", Vector2i(1,1) : "Eright_wall" }, "persp_up_wall": {Vector2i(0, -1) : "wall", Vector2i(1,-1) : "Ewall"}}],
	9: [{"main": "normal", "persp_down_water": "down_wall", "persp_right_wall": { Vector2i(1,0) : "normal", Vector2i(1,1) : "Eright_wall" }, "persp_up_wall": {Vector2i(1,-1) : "Ewall"}}],
	10: [{"main": "normal", "persp_down_water": "down_wall", "persp_up_wall": {Vector2i(0, -1) : "wall"}}],
	11: [{"main": "normal", "persp_down_water": "down_wall"}],
	12: [{"main" : "full", "persp_right_wall": "normal", "persp_up_wall": {Vector2i(0, -1) : "wall", Vector2i(1,-1) : "Ewall"}}],
	13: [{"main" : "full", "persp_right_wall": "normal", "persp_up_wall": {Vector2i(1,-1) : "Ewall"}}],
	14: [{"main" : "full", "persp_up_wall": {Vector2i(0, -1) : "wall"}}],
	15: [{"main" : "full"}]
}
