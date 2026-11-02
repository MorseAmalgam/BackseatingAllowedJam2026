extends Control


func _on_replay_level_button_pressed() -> void:
	$"/root/Main".reload_current_scene()


func _on_next_mission_button_pressed() -> void:
	ProgressManager.current_level += 1
	ProgressManager.map_seed = 0  # new level, new layout
	$"/root/Main".reload_current_scene()


func _on_quit_to_title_screen_button_pressed() -> void:
	$"/root/Main".navigate_to_screen(Main.InterfaceScreens.TITLE)


func _on_quit_to_desktop_button_pressed() -> void:
	$"/root/Main".exit_game()
