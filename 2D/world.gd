extends Node

@onready var _radar_window: Window = $RadarWindow

func _ready():
	@warning_ignore("integer_division")
	_radar_window.position = get_window().position + (get_window().size / 2) - ($RadarWindow.size / 2)
