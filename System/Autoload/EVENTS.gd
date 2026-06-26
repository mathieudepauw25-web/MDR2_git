extends Node


signal starting()
signal save()
signal paused()

signal create_floor_tile(v_global_position: Vector2)
signal erase_floor_tile(v_global_position: Vector2)

signal splash(v_global_position: Vector2)
signal waterDash(v_global_position: Vector2, v_direction: Vector2)

signal show_Dspot(starting_position: Vector2)
signal hide_Dspot()

signal superdash_run()

signal player_move()
signal player_dash()
signal player_pok()
signal player_fall()
signal player_inaction()

signal door2()

signal collect_key(nb_key, nb_key_need)

signal options(index_option: int)
signal close_option()

signal shake_camera()

signal update_star_data()
signal collect_start(index_star)

signal arrival()
signal trophy_resume_free()

signal hidden_tiles(reveal: bool)

signal get_leaderboard_top_world()
