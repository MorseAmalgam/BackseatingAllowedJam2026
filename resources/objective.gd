class_name MissionObjective
extends Resource

enum ObjectiveState {
	IN_PROGRESS,
	COMPLETED,
	FAILED
}


var state:ObjectiveState = ObjectiveState.IN_PROGRESS


func get_description() -> String:
	return "Survive"


func init(_world:World) -> void:
	pass


func update() -> void:
	pass
