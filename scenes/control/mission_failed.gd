extends Control


func _on_retry_level_button_pressed() -> void:
	$"/root/Main".reload_current_scene()


func _on_return_to_map_button_pressed() -> void:
	$"/root/Main".navigate_to_screen(Main.InterfaceScreens.MAP)


func _on_quit_to_title_screen_button_pressed() -> void:
	$"/root/Main".navigate_to_screen(Main.InterfaceScreens.TITLE)


func _on_quit_to_desktop_button_pressed() -> void:
	$"/root/Main".exit_game()
