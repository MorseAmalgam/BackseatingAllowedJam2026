extends Window

var is_held:bool = false
var click_point:Vector2i


func _ready() -> void:
	RenderingServer.frame_pre_draw.connect(_world_update)
	RenderingServer.frame_post_draw.connect(_radar_update)


func check_held_changed(mouse_state:bool)->bool:
	var check = mouse_state != is_held
	is_held = mouse_state
	return check


func _process(_delta: float) -> void:
	if check_held_changed(Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)) && is_held:
		click_point = get_viewport().get_mouse_position()
	
	if Input.is_action_just_pressed("hotbar_1"):
		$ColorRect.color = Color.RED
	elif Input.is_action_just_pressed("hotbar_2"):
		$ColorRect.color = Color.BLUE
	elif Input.is_action_just_pressed("hotbar_3"):
		$ColorRect.color = Color.GREEN
	elif Input.is_action_just_pressed("hotbar_4"):
		$ColorRect.color = Color.PURPLE
	
	# Update region info for command pinpointing
	$CoordinateIndicator.text = "RGN: <%s, %s>" % [position.x, position.y]

func _world_update():
	if is_held:
		$Field.global_position = -Vector2(position.x, position.y) + Vector2(DisplayServer.window_get_position_with_decorations(0))
		position = DisplayServer.mouse_get_position() - click_point
	pass

func _radar_update():
	pass
