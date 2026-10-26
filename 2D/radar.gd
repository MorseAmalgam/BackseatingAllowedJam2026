extends Window

enum Scans {
	MOTION = 1,
	INFRARED = 2,
	SEISMIC = 3,
	HEAT = 4
}


var is_held:bool = false
var click_point:Vector2i


func _ready() -> void:
	pass


func check_held_changed(mouse_state:bool)->bool:
	var check = mouse_state != is_held
	is_held = mouse_state
	return check


func _process(_delta: float) -> void:
	if get_focused_window() == self && check_held_changed(Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)) && is_held:
		click_point = get_viewport().get_mouse_position()
	
	if Input.is_action_just_pressed("hotbar_1"):
		_update_scan_indicators(Scans.MOTION)
	elif Input.is_action_just_pressed("hotbar_2"):
		_update_scan_indicators(Scans.INFRARED)
	elif Input.is_action_just_pressed("hotbar_3"):
		_update_scan_indicators(Scans.SEISMIC)
	elif Input.is_action_just_pressed("hotbar_4"):
		_update_scan_indicators(Scans.HEAT)
	
	if is_held:
		position = DisplayServer.mouse_get_position() - click_point
	
	# Actually seems a tiny bit more responsive if you cut down the number of updates
	var target_position = -Vector2(position.x, position.y) + Vector2(DisplayServer.window_get_position_with_decorations(0))
	if ($Field.position.distance_to(target_position) > 0.01):
		$Field.position = target_position
		$ScannerUI/CoordinateIndicator.text = "TRIANGULATING..."
		$TriangulationTimer.start()
	


func _update_scan_indicators(active:int)->void:
	canvas_cull_mask = 1 + (1 << active)
	var scans:Array = $ScannerUI/ScanIndicators.get_children()
	for index in range(scans.size()):
		scans[index].modulate = Color.WHITE if index+1 == active else Color.BLACK
		

func _world_update():
	if is_held:
		position = DisplayServer.mouse_get_position() - click_point
	
	var target_position = -Vector2(position.x, position.y) + Vector2(DisplayServer.window_get_position_with_decorations(0))
	if ($Field.position.distance_to(target_position) > 0.01):
		$Field.position = target_position
		$ScannerUI/CoordinateIndicator.text = "TRIANGULATING..."
		$TriangulationTimer.start()
	pass


func _on_triangulation_timer_timeout() -> void:
	# Update region info for command pinpointing
	var pos = Vector2(position.x, position.y) - Vector2(DisplayServer.window_get_position_with_decorations(0))
	$ScannerUI/CoordinateIndicator.text = "RGN: <%s, %s>" % [pos.x, pos.y]
	pass
