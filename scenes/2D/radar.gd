extends Window

enum Scans {
	MOTION = 1,
	INFRARED = 2,
	VIBRATION = 3,
	THERMAL = 4
}

# 3 is the magic number here. 2 still has critter jiggle. 
const DRAG_DELAY_FRAMES := 3

var is_held:bool = false
var click_point:Vector2i
var target_queue:Array[Vector2i] = []   # drag targets, oldest first

func check_held_changed(mouse_state:bool)->bool:
	var check = mouse_state != is_held
	is_held = mouse_state
	return check


func _process(_delta: float) -> void:
	# Mouse drag for sensor array
	if get_focused_window() == self && check_held_changed(Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)) && is_held:
		click_point = get_viewport().get_mouse_position()
		# Prefill the queue so the window stays put until the delay has elapsed
		target_queue.clear()
		for i in DRAG_DELAY_FRAMES:
			target_queue.push_back(position)

	# Update the window position if we're dragging it
	if is_held:
		target_queue.push_back(DisplayServer.mouse_get_position() - click_point)
		position = target_queue.pop_front()   # target from DRAG_DELAY_FRAMES ago
	elif not target_queue.is_empty():
		position = target_queue.pop_front()   # released: walk out the remaining targets

	# Actually seems a tiny bit more responsive if you cut down the number of updates
	# Camera uses the newest target while the window is still catching up
	var window_pos = target_queue.back() if not target_queue.is_empty() else position
	var target_position = Vector2(window_pos) - Vector2(DisplayServer.window_get_position_with_decorations(0))
	if ($Camera2D.position.distance_to(target_position) > 0.01):
		$Camera2D.position = target_position
		$Camera2D/ScannerUI/CoordinateIndicator.text = "TRIANGULATING..."
		$TriangulationTimer.start()
	
	# STOP HERE if the game is paused - screen movement is only for the purposes of getting it out of the way
	if get_tree().paused:
		return
	
	if Input.is_action_just_pressed("hotbar_1") && ProgressManager.sensor_progression.has("motion"):
		_update_scan_indicators(Scans.MOTION)
	elif Input.is_action_just_pressed("hotbar_2") && ProgressManager.sensor_progression.has("infrared"):
		_update_scan_indicators(Scans.INFRARED)
	elif Input.is_action_just_pressed("hotbar_3") && ProgressManager.sensor_progression.has("vibration"):
		_update_scan_indicators(Scans.VIBRATION)
	elif Input.is_action_just_pressed("hotbar_4") && ProgressManager.sensor_progression.has("thermal"):
		_update_scan_indicators(Scans.THERMAL)


func activate() -> void:
	visible = true
	
	# TODO: Soft-enable sensor indicators
	pass


func _update_scan_indicators(active:int)->void:
	canvas_cull_mask = 1 + (1 << active)
	var scans:Array = $Camera2D/ScannerUI/ScanIndicators.get_children()
	for index in range(scans.size()):
		scans[index].modulate = Color.WHITE if index+1 == active else Color.BLACK


func _on_triangulation_timer_timeout() -> void:
	# Update region info for command pinpointing
	var pos = (
		Vector2(position.x, position.y) - 
		Vector2(DisplayServer.window_get_position_with_decorations(0)) + 
		Vector2(DisplayServer.window_get_size(1) / 2.0)
		)
	$Camera2D/ScannerUI/CoordinateIndicator.text = "RGN: <%s, %s>" % [pos.x, pos.y]
	pass
