class_name TimerObjective
extends MissionObjective

@export var timer:int = 60
@export var custom_message:String

var countdown:float

func get_description() -> String:
	if (custom_message.is_empty()):
		return "Hold out until extraction (%01d:%02d)" % [countdown / 60.0, floori(countdown) % 60]
	else:
		return "%s (%01d:%02d)" % [custom_message, countdown / 60., floori(countdown) % 60]

func init(world:World) -> void:
	countdown = timer
	pass

func update()->void:
	if (countdown > 0):
		countdown -= Engine.get_main_loop().root.get_process_delta_time()
	else:
		countdown = 0.0
		state = ObjectiveState.COMPLETED
	
