class_name World
extends Node

@onready var _radar_window: Window = $RadarWindow
@warning_ignore("unused_variable")
@onready var _vessel: Vessel = $Vessel

func _ready():
	# TODO: Enable menu and chat interaction after anything else 
	
	_start_gameplay()
	
	@warning_ignore("integer_division")
	_radar_window.position = get_window().position + (get_window().size / 2) - ($RadarWindow.size / 2)

func _start_gameplay() -> void:
	# Enable pause menu
	$"/root/Main".menu_enabled = true
	
	# Activate sensor window
	_radar_window.activate()
	
	# Connect to weapons platform - only listen for commands for weapons we have enabled.
	for weapon in ProgressManager.weapon_progression:
		TwitchService.instance.get_node(weapon).command_received.connect(Callable(self, "_on_received_fire_command"))

	pass

func _on_received_fire_command(_from_username: String, info: TwitchCommandInfo, _args: PackedStringArray) -> void:
	match info.command:
		"!flak":
			pass
		"!laser":
			pass
		"!bunker":
			pass
		"!thumper":
			pass
		"!flare":
			pass
	print(info.command)
	pass
