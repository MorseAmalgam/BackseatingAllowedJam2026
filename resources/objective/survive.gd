class_name SurviveObjective
extends MissionObjective


var target:Node2D


func get_description() -> String:
	return "Vessel must be extracted"

func init(world:World) -> void:
	target = world.vessel
	state = ObjectiveState.COMPLETED

func update() -> void:
	if target == null:
		state = ObjectiveState.FAILED
