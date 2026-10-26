extends Node


func _on_return_to_game_button_pressed() -> void:
	# Main already has all the logic for pausing/unpausing, so just call that.
	$"/root/Main".toggle_pause()
	pass # Replace with function body.


func _on_restart_level_button_pressed() -> void:
	pass # Replace with function body.


func _on_return_to_map_button_pressed() -> void:
	pass # Replace with function body.


func _on_quit_to_title_screen_button_pressed() -> void:
	# Toggle pause so we can process the scene change.
	$"/root/Main".toggle_pause()
	SceneLoader.change_scene("res://scenes/control/title_screen.tscn")


func _on_quit_to_desktop_button_pressed() -> void:
	# This should probably have a confirmation, but I'm too lazy to make ANOTHER popup.
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	get_tree().quit()
	pass
