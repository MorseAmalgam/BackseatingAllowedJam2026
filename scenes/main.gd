class_name Main
extends Node

var menu_enabled:bool = false
const InterfaceScreens:Dictionary = {
	TITLE = "res://scenes/control/title_screen.tscn",
	MAP = "res://scenes/control/map.tscn",
}


func _ready() -> void:
	# Prep our SceneLoader
	SceneLoader.scene_loaded.connect(_on_scene_loaded)
	SceneLoader.scene_load_requested.connect(_on_scene_load_requested)
	SceneLoader.current_scene = $ActiveScene/TitleScreen


func _process(_delta: float) -> void:
	# Toggle for our menu
	if menu_enabled && Input.is_action_just_pressed("ui_cancel"):
		toggle_pause()
	pass


func exit_game() -> void:
	# This should probably have a confirmation, but I'm too lazy to make ANOTHER popup.
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	get_tree().quit()


func navigate_to_screen(scene_path:String) -> void:
	# Toggle pause so we can process the scene change.
	toggle_pause()
	SceneLoader.change_scene(scene_path)

func show_mission_complete() -> void:
	menu_enabled = false
	$MissionComplete.visible = true
	pass


func show_mission_failed() -> void:
	menu_enabled = false
	$MissionFailed.visible = true
	pass


func toggle_pause() -> void:
	# Show our menu
	$Menu.visible = !$Menu.visible
	# Pause the game
	get_tree().paused = $Menu.visible


func _on_scene_load_requested() -> void:
	# Hide the menu so it's not still up when the transition finishes.
	$Menu.visible = false
	# Disable the menu - it's unlikely we'd want it immediately accessible again.
	menu_enabled = false
	# Disable GreenHeat so that it can't do anything silly until we tell it to.
	if get_node_or_null("GreenHeat") != null:
		$GreenHeat.detecting = false
		
	pass


func _on_scene_loaded(new_scene:Node):
	# Logic dictates that there should only ever be one child in the ActiveScene.
	# But why chance it?
	for child in $ActiveScene.get_children():
		child.queue_free()
	
	# Add our new scene
	new_scene.position = Vector2.ZERO
	$ActiveScene.add_child(new_scene)
