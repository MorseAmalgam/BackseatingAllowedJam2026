extends Window

var is_held:bool = false
var click_point:Vector2i

func _input(event: InputEvent) -> void:
	# Ignore all non-mouse input
	if event is not InputEventMouseButton and event is not InputEventMouseMotion:
		return
	
	# Mouse click
	if event is InputEventMouseButton:
		is_held = event.button_index == 1 and event.pressed
		if is_held:
			click_point = event.position
		print(is_held, click_point)
		pass
	# Mouse Movement while held
	elif event is InputEventMouseMotion and is_held:
		printt(DisplayServer.mouse_get_position())
		position = DisplayServer.mouse_get_position() - click_point
		print(event.position)
		pass
	
	pass
