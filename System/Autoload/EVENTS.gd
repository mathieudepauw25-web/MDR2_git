extends Node


@warning_ignore("unused_signal")
signal starting()
@warning_ignore("unused_signal")
signal save()
@warning_ignore("unused_signal")
signal paused()

@warning_ignore("unused_signal")
signal create_floor_tile(v_global_position: Vector2)
@warning_ignore("unused_signal")
signal erase_floor_tile(v_global_position: Vector2)

@warning_ignore("unused_signal")
signal splash(v_global_position: Vector2)
@warning_ignore("unused_signal")
signal waterDash(v_global_position: Vector2, v_direction: Vector2)

@warning_ignore("unused_signal")
signal show_Dspot(starting_position: Vector2)
@warning_ignore("unused_signal")
signal hide_Dspot()

@warning_ignore("unused_signal")
signal superdash_run()

@warning_ignore("unused_signal")
signal player_move()
@warning_ignore("unused_signal")
signal player_dash()
@warning_ignore("unused_signal")
signal player_pok()
@warning_ignore("unused_signal")
signal player_fall()
@warning_ignore("unused_signal")
signal player_inaction()

@warning_ignore("unused_signal")
signal door2()

@warning_ignore("unused_signal")
signal collect_key(nb_key, nb_key_need)

@warning_ignore("unused_signal")
signal options(index_option: int)
@warning_ignore("unused_signal")
signal close_option()

@warning_ignore("unused_signal")
signal shake_camera()

@warning_ignore("unused_signal")
signal update_star_data()
@warning_ignore("unused_signal")
signal collect_start(index_star)

@warning_ignore("unused_signal")
signal arrival()
@warning_ignore("unused_signal")
signal trophy_resume_free()

@warning_ignore("unused_signal")
signal hidden_tiles(reveal: bool)

@warning_ignore("unused_signal")
signal get_leaderboard_top_world()
