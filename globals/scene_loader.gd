extends Node

signal scene_loaded(current_scene)
signal scene_load_requested

var current_scene:Node
var current_scene_path:String
var loading_scene_path:String

func change_scene(file_path:String):
	# Meant to prevent accidentally hitting the scene transition if we're already on the scene
	if (current_scene_path == file_path):
		return
	
	# Let things know we're transitioning to a new scene
	scene_load_requested.emit()
	
	# Sound effect?
	$AudioStreamPlayer.play()
	# Play the actual transition
	$AnimationPlayer.play("FadeIn")
	# Don't unload things until everything's hidden
	await $AnimationPlayer.animation_finished
	# Extra delay because, weirdly, transitions felt TOO abrupt at times otherwise
	await get_tree().create_timer(0.35).timeout
	# Unload current scene if one exists
	if (current_scene != null):
		current_scene.queue_free()
	
	# Asyncronously load new scene
	loading_scene_path = file_path
	ResourceLoader.load_threaded_request(loading_scene_path)
	pass

	
func _process(_delta: float) -> void:
	# Get the load progress
	var progress:Array = []
	var load_status = ResourceLoader.load_threaded_get_status(loading_scene_path, progress)
	
	# If complete, transition to new scene
	if load_status == ResourceLoader.ThreadLoadStatus.THREAD_LOAD_LOADED:
		var loaded_packed_scene = ResourceLoader.load_threaded_get(loading_scene_path)
		current_scene_path = loading_scene_path
		current_scene = loaded_packed_scene.instantiate()
		
		# Let things know we're ready
		scene_loaded.emit(current_scene)
		# Back to the show!
		$AnimationPlayer.play("FadeOut")
	pass
