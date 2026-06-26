extends Node2D
class_name Challenge

@export var challenge_data: Resource = null: set = set_challenge_data
@onready var node_sprite_2d: Sprite2D = %Sprite2D

func _ready() -> void :
    node_sprite_2d.set_texture(challenge_data.chall_texture)


func set_challenge_data(value: Resource) -> void :
    challenge_data = value
