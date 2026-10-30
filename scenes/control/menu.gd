extends Node


func _on_return_to_game_button_pressed() -> void:
	# Main already has all the logic for pausing/unpausing, so just call that.
	$"/root/Main".toggle_pause()
	pass # Replace with function body.


func _on_restart_level_button_pressed() -> void:
	pass # Replace with function body.


func _on_return_to_map_button_pressed() -> void:
	$"/root/Main".navigate_to_screen(Main.InterfaceScreens.MAP)


func _on_quit_to_title_screen_button_pressed() -> void:
	$"/root/Main".navigate_to_screen(Main.InterfaceScreens.TITLE)


func _on_quit_to_desktop_button_pressed() -> void:
	$"/root/Main".exit_game()
